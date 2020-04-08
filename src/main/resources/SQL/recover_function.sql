CREATE OR REPLACE FUNCTION recover_function(recover_date timestamp)
RETURNS integer AS $$
begin
	/*удаляем из TARGET все, что свежее указанной даты*/
	delete from bank_additional_merge
	where valid_from >= recover_date;

	raise notice 'TARGET table has been cleaned since %', recover_date;

  /*отбираем самые свежие данный из HIST за указанный срез данных*/
  insert into bank_additional_merge
    select * from bank_additional_hist bah
    where valid_from >= recover_date
      and valid_to is null;
  raise notice 'TARGET table has been updated from HIST since %', recover_date;

  return 0;

  exception
  when others then
    RAISE INFO 'Error Name:%',SQLERRM;
    RAISE INFO 'Error State:%', SQLSTATE;
    return -1;
end;
$$
LANGUAGE plpgsql;