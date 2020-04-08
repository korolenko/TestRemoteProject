CREATE OR REPLACE FUNCTION test_merge_with_history()
RETURNS integer AS $$
begin
	/*блокируем инкрементальную таблицу на запрет изменения данных в ней
	 до момента окончания работы процедуры*/
	LOCK TABLE public.bank_additional_inc IN ROW EXCLUSIVE MODE;
	
	LOCK TABLE public.bank_additional_merge IN ROW EXCLUSIVE MODE;
	/*если обнаружена связка по ключу в TARGET-таблице с инкрементальными данными, делаем insert "устаревших"
	 * данных из TARGET в HIST*/
	insert into bank_additional_hist 
			select 	bam."age",
					bam.job,
					bam.marital,
					bam.education,
					bam."default",
					bam.housing,
					bam.loan,
					bam.contact,
					bam."month",
					bam.day_of_week,
					bam.duration,
					bam.campaign,
					bam.pdays,
					bam.previous,
					bam.poutcome,
					bam."emp.var.rate",
					bam."cons.price.idx",
					bam."cons.conf.idx",
					bam.euribor3m,
					bam."nr.employed",
					bam.y,
					bam.valid_from,
					actual_inc.valid_from, -- проставляем признак "устаревшей" записи
					bam.merge_operation  
	from bank_additional_merge bam
	inner join 
		(		/*отбираем самые свежие записи по каждому ключу, пришедшие в INC*/
						select * from 
						(
						select row_number() over(partition by duration order by valid_from desc) as rn,
								duration,
								valid_from,valid_to
						  from bank_additional_inc	bai
						)a
						where a.rn = 1
					)actual_inc
	on bam.duration = actual_inc.duration
	and bam.valid_from < actual_inc.valid_from;
	
	/*меняем в TARGET устаревшие записи на новые*/
	update bank_additional_merge target
		set	"age" = to_update."age",
			job = to_update.job,
			marital = to_update.marital,
			education = to_update.education,
			"default" = to_update."default",
			housing = to_update.housing,
			loan = to_update.loan,
			contact = to_update.contact,
			"month" = to_update."month",
			day_of_week = to_update.day_of_week,
			duration = to_update.duration,
			campaign = to_update.campaign,
			pdays = to_update.pdays,
			previous = to_update.previous,
			poutcome = to_update.poutcome,
			"emp.var.rate" = to_update."emp.var.rate",
			"cons.price.idx" = to_update."cons.price.idx",
			"cons.conf.idx" = to_update."cons.conf.idx",
			euribor3m = to_update.euribor3m,
			"nr.employed" = to_update."nr.employed",
			y = to_update.y,
			valid_from = to_update.valid_from,
			 valid_to = null, -- проставляем признак "актуальной" записи
			merge_operation = to_update.merge_operation
	from 	bank_additional_inc to_update
	inner join
	(
	/*отбираем самые свежие записи по каждому ключу, пришедшие в INC*/
		select * from 
		(
			select row_number() over(partition by duration order by valid_from desc) as rn,
					duration,
					valid_from,valid_to
			from bank_additional_inc bai
		)a
		where a.rn = 1
	)actual_inc
	on to_update.duration = actual_inc.duration
	and to_update.valid_from = actual_inc.valid_from
	where target.duration = to_update.duration
	and target.valid_from < to_update.valid_from;
	
	
	/*если в INC имеется больше 1 записи по ключу, всем кроме самой свежей корректно проставляем признак устаревшей записи и записываем их в HIST*/
	insert into bank_additional_hist 
	select ins_val."age",
					ins_val.job,
					ins_val.marital,
					ins_val.education,
					ins_val."default",
					ins_val.housing,
					ins_val.loan,
					ins_val.contact,
					ins_val."month",
					ins_val.day_of_week,
					ins_val.duration,
					ins_val.campaign,
					ins_val.pdays,
					ins_val.previous,
					ins_val.poutcome,
					ins_val."emp.var.rate",
					ins_val."cons.price.idx",
					ins_val."cons.conf.idx",
					ins_val.euribor3m,
					ins_val."nr.employed",
					ins_val.y,
					ins_val.valid_from,
					ins_val.new_valid_to,
					ins_val.merge_operation
	from (
		select 
			lead(a.valid_from, 1) over (partition by a.duration order by a.valid_from) as new_valid_to,
			* 
			from (
			select * from bank_additional_inc bai
			union
			select  * from bank_additional_merge 
			where duration in (select distinct duration from bank_additional_inc) /*если в INC пришла устаревшая запись*/
			and valid_from >= (select min(valid_from) from bank_additional_inc) 
			union
			select  * from bank_additional_hist 
			where duration in (select distinct duration from bank_additional_inc) /*2 последних условия, чтобы не тянуть все что уже есть в истории*/
			and valid_from >= (select min(valid_from) from bank_additional_inc)  /*но при этом корректно обработать ситуацию, когда в INC есть данные по одному*/
			)a																	/*ключу одновременно и старше и свежее того, что есть в TARGET*/
		)ins_val
	where /*new_valid_to is not null
	and ins_val.valid_to is null
	and */
	not exists (select 1 from bank_additional_hist bah
	where bah.duration = ins_val.duration
		and bah.valid_from = ins_val.valid_from);
		--and bah.valid_to = new_valid_to);
	
	/*записываем в TARGET оставшиеся данные из INC, по которым нет связки по ключу*/
	insert into bank_additional_merge 
	select * from bank_additional_inc bac
	where not exists (
	select 1 from bank_additional_merge bam
	where bac.duration = bam.duration);

	return 0;

	exception
    when others then
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
        return -1;
end;
$$
LANGUAGE plpgsql;
