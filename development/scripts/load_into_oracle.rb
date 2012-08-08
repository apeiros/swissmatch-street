streets = Marshal.load(File.open('data/streets.marshal'));0
ActiveRecord::Migration.create_table :swissmatch_streets do |t|
  t.string :canton
  t.string :community
  t.string :street_name
  t.string :simplified_street_name
  t.timestamps
end
module SwissMatch; end
class SwissMatch::Street < ActiveRecord::Base
  self.table_name = :swissmatch_streets
end
def print_time(iter, before, now)
  printf "%5d: %s (%.1fs)\n", iter, now.strftime("%H:%M:%S"), before-now
end

raw_db          = ActiveRecord::Base.connection.instance_variable_get(:@connection).raw_connection
begin
  batch_size      = 10_000
  sql    =   <<-SQL
    INSERT INTO swissmatch_streets
    (id, canton, community, street_name, simplified_street_name, updated_at, created_at)
    VALUES (
      SWISSMATCH_STREETS_SEQ.nextval,
      :1,
      :2,
      :3,
      Utl_People.normalize_matchable(:4),
      sysdate,
      sysdate
    )
  SQL
  now       = Time.now
  iter      = 0
  start     = now
  inserter  = raw_db.parse(sql)
  inserter.max_array_size = batch_size
  print_time(0, now, now)

  measure = Benchmark.measure do
    streets.each_slice(batch_size) do |insertion|
      inserter.close
      inserter = raw_db.parse(sql)
      inserter.max_array_size = batch_size

      cantons, communities, street_names = *insertion.transpose
      inserter.bind_param_array(1, cantons, String)
      inserter.bind_param_array(2, communities, String)
      inserter.bind_param_array(3, street_names, String)
      inserter.bind_param_array(4, street_names, String)
      inserter.exec_array
      before = now
      now    = Time.now
      print_time(iter+=1, now, before)
    end
  end
  puts "#{iter} Iterations"
end