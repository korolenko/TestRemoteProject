CREATE OR REPLACE FUNCTION test_merge()
RETURNS integer AS $$
DECLARE
	inc_cursor refcursor;
	inc_row RECORD;
begin
	/*блокируем инкрементальную таблицу на запрет изменения данных в ней
	 до момента окончания работы процедуры*/
	LOCK TABLE public.bank_additional_inc IN ROW EXCLUSIVE MODE;
	/*нужно ли?*/
	LOCK TABLE public.bank_additional IN ROW EXCLUSIVE MODE;

	OPEN inc_cursor FOR SELECT * FROM public.bank_additional_inc bai;

	loop
		fetch inc_cursor into inc_row;
		EXIT WHEN NOT FOUND;

		/*поиск в TARGET таблице действующего значения с ключем из инкремента
		 если такое имеется, делаем его неактивным, путем установления в поле valid_to
		 значения из поля valid_from строки инкремента, в том случае,
		 если у строки в TARGET значение valid_from меньше чем в строке инкремента*/
		update bank_additional
			set valid_to = inc_row.valid_from
		where valid_to  is null
			and duration = inc_row.duration
			and valid_from <= inc_row.valid_from;

		raise notice 'the row was marked as inactive, duration: %', inc_row.duration;

		/*записываем в таргет инкрементальную запись*/
		insert into public.bank_additional
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
		values(
			inc_row."age",
			inc_row.job,
			inc_row.marital,
			inc_row.education,
			inc_row."default",
			inc_row.housing,
			inc_row.loan,
			inc_row.contact,
			inc_row."month",
			inc_row.day_of_week,
			inc_row.duration,
			inc_row.campaign,
			inc_row.pdays,
			inc_row.previous,
			inc_row.poutcome,
			inc_row."emp.var.rate",
			inc_row."cons.price.idx",
			inc_row."cons.conf.idx",
			inc_row.euribor3m,
			inc_row."nr.employed",
			inc_row.y,
			inc_row.valid_from,
			inc_row.valid_to,
			inc_row.merge_operation
		);
		raise notice 'the inc row was inserted, duration: %', inc_row.duration;
	end loop;

	CLOSE inc_cursor;

	return 0;

	exception
    when others then
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
        return -1;
end;
$$
LANGUAGE plpgsql;
