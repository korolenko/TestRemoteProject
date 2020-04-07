CREATE OR REPLACE FUNCTION test_merge()
RETURNS integer AS $$
begin
	/*блокируем инкрементальную таблицу на запрет изменения данных в ней
	 до момента окончания работы процедуры*/
	LOCK TABLE public.bank_additional_inc IN ROW EXCLUSIVE MODE;
	/*нужно ли?*/
	LOCK TABLE public.bank_additional_merge IN ROW EXCLUSIVE MODE;

	/*создаем темповую таблицу для пометки устаревшими инкрементальных данных, если по одному ключу пришло больше одной записи*/
	CREATE TEMPORARY TABLE to_insert2
   	(
      	"age" numeric NULL,
		job text NULL,
		marital text NULL,
		education text NULL,
		"default" text NULL,
		housing text NULL,
		loan text NULL,
		contact text NULL,
		"month" text NULL,
		day_of_week text NULL,
		duration numeric NULL,
		campaign numeric NULL,
		pdays numeric NULL,
		previous numeric NULL,
		poutcome numeric NULL,
		"emp.var.rate" numeric NULL,
		"cons.price.idx" numeric NULL,
		"cons.conf.idx" numeric NULL,
		euribor3m numeric NULL,
		"nr.employed" numeric NULL,
		y text NULL,
		valid_from timestamp NULL,
		valid_to timestamp NULL,
		merge_operation text NULL
   	) 
   	ON COMMIT DROP;
	
   raise notice 'temp table created';
	/*проставляем признак устаревшей записи в TARGET-таблице для тех значений, с которыми есть связка по ключу, и которые раньше были актуальными*/
	update 
		bank_additional_merge target
	set
		valid_to = to_update.valid_from 
	from 
		bank_additional_inc to_update
			/*отбираем данные из инкрементальной таблицы*/
			inner join
				(
					/*находим записи, которые совпадают с тем, что уже есть в Target таблице*/
					select  bai.duration, bai.valid_from ,
							row_number() over(partition by bai.duration order by bai.valid_from desc) as rn -- если в инкремент пришло более одной записи с одинаковым ключом
					from public.bank_additional_inc bai 
					inner join public.bank_additional_merge bam
						on bai.duration = bam.duration
						and bam.valid_to  is null -- нужна только действующая запись
						and bam.valid_from <= bai.valid_from -- если в TARGET-таблице срок действия записи более свежий, чем в инкременте, то оставляем то, что уже в TARGET
				)sb
			on to_update.duration = sb.duration and to_update.valid_from  = sb.valid_from and sb.rn = 1
			where target.valid_to is null
			and target.duration = to_update.duration;
		
	raise notice '1 update';

	/*Инсертим все новые инкрементальные данные в темп-таблицу*/
	insert into to_insert2
			(
				"age",
				job,
				marital,
				education,
				"default",
				housing,
				loan,
				contact,
				"month",
				day_of_week,
				duration,
				campaign,
				pdays,
				previous,
				poutcome,
				"emp.var.rate",
				"cons.price.idx",
				"cons.conf.idx",
				euribor3m,
				"nr.employed",
				y,
				valid_from,
				valid_to,
				merge_operation
			)
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
				null, -- на данном этапе всем новым записям проставляется признак активной записи
				ins_val.merge_operation
			from public.bank_additional_inc ins_val;
			
		raise notice 'temp insert';
	
			/*оставляем в темп таблице только одну запись по каждому ключу активной*/
			/*проставляем всем записям по одному ключу (кроме того у которого самое свежее значение) значение в valid_to*/
			update to_insert2 target
				set valid_to = b.valid_from
				from (
					/*отбираем самые свежие записи по каждому ключу*/
					select * from 
					(
					select row_number() over(partition by duration order by valid_from desc) as rn,
							duration,
							valid_from
					  from to_insert2
					  		
					)a
					where a.rn = 1
				)b
				where target.duration = b.duration
					and target.valid_from <> b.valid_from;
				
	raise notice '2 update';
	/*финальный инсерт обработанного инкремента в TARGET таблицу*/
	insert into public.bank_additional_merge 
	select * from to_insert2;
	
	raise notice '2 insert';

	return 0;

	exception
    when others then
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
        return -1;
end;
$$
LANGUAGE plpgsql;
