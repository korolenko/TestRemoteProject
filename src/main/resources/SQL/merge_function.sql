CREATE OR REPLACE FUNCTION public.test_merge()
	RETURNS int4
	LANGUAGE plpgsql
	VOLATILE
AS $$
begin
	/*блокируем инкрементальную таблицу на запрет изменения данных в ней
	 до момента окончания работы процедуры*/
	LOCK TABLE public.bank_additional_inc IN ROW EXCLUSIVE MODE;
	/*нужно ли?*/
	LOCK TABLE public.bank_additional_merge IN ROW EXCLUSIVE MODE;

	/*Апдейтим в TARGET-таблице те значения, с которыми есть связка по ключу*/
	update
		bank_additional_merge target
	set
				"age" = to_update."age",
				job   = to_update.job,
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
		   valid_to = null, -- проставляем признак актуальной записи
	  merge_operation = to_update.merge_operation
	from
		bank_additional_inc to_update
			/*отбираем данные из инкрементальной таблицы*/
			where target.duration in
				(
				/*находим записи, которые совпадают с тем, что уже есть в Target таблице*/
				select bai.duration from public.bank_additional_inc bai
				inner join public.bank_additional_merge bam
				on bai.duration = bam.duration
				and bam.valid_to  is null -- нужна только действующая запись
				and bam.valid_from <= bai.valid_to -- если в TARGET-таблице срок действия записи более свежий, чем в инкременте, то оставляем то? что уже в TARGET
				)
			and target.valid_to is null;

	/*Инсертим новые данные в TARGET-таблицу*/
	insert into public.bank_additional_merge
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
				ins_val.valid_to,
				ins_val.merge_operation
			from bank_additional_inc ins_val
			/*отобрали данные на insert*/
			where duration not in
			(
			/*находим записи, которые совпадают с тем, что уже есть в Target таблице*/
			select bai.duration from public.bank_additional_inc bai
			inner join public.bank_additional_merge bam
			on bai.duration = bam.duration
			and bam.valid_to  is null
			);

	return 0;

	exception
    when others then
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
        return -1;
end;
 $$
;
