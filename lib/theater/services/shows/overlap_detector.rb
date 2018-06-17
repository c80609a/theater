module Services
  module Shows
    class OverlapDetector

      QUERY_SELECT_ALL = 'SELECT start_at,stop_at FROM shows'
      TPL_RANGE        = "DATE '%s', DATE '%s' + INTERVAL '1 day'"              # 1 день добавляем, т.к. `start <= time < end`

      # Вернёт true, если Спектакль с
      # указанными датами начала/окончания
      # "наслаивается" на уже имеющиеся в базе
      #
      # К базе будет совершено 2 запроса.
      #
      def perform(start_at, stop_at)
        all = ActiveRecord::Base.connection.execute QUERY_SELECT_ALL
        return false if all.count.zero?
        sql = _build_overlap_sql start_at, stop_at, all
        ActiveRecord::Base.connection.execute(sql)[0]['is_overlap']
      end

      private

      # Построит SQL вида:
      #
      # SELECT (
      #   (SELECT (show) OVERLAP (show1)) AND
      #   (SELECT (show) OVERLAP (show2)) AND
      #   ...
      # )
      #
      # в котором добавляемый Спектакль сравнивается на предмет наслаиваний
      # с уже имеющимися в базе.
      #
      # @param [Date]   start_at
      # @param [Date]   stop_at
      # @param [Array]  all_ranges [{'start_at': '', 'stop_at': ''}, <...>]
      #
      def _build_overlap_sql(start_at, stop_at, all_ranges)
        show = TPL_RANGE % [start_at, stop_at]

        sql  = all_ranges.map do |e|
          showi = TPL_RANGE % [e['start_at'], e['stop_at']]
          '(SELECT (%s) OVERLAPS (%s))' % [show, showi]
        end * ' OR '

        'SELECT(%s) AS is_overlap' % sql
      end

    end
  end
end
