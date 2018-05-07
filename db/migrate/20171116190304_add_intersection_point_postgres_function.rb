# frozen_string_literal: true

class AddIntersectionPointPostgresFunction < ActiveRecord::Migration[5.1]
  def change
    sql = <<-SQL
      CREATE OR REPLACE FUNCTION intersection_point(multiline geometry, city_name text) RETURNS geometry AS $$
        declare
          boundary geometry;
          intersection geometry;
          difference geometry;
        BEGIN
          boundary := (SELECT boundaries FROM cities WHERE name=$2 LIMIT 1)::geometry;
          intersection := ST_Intersection(multiline, boundary);
          difference := ST_Difference(multiline, boundary);
          RETURN ST_Intersection(intersection, difference);
        END;
      $$ LANGUAGE plpgsql;
    SQL

    connection.execute(sql)
  end
end
