# frozen_string_literal: true

class Event < ApplicationRecord
  # TODO: implement validations and kind of events

  enum kind: { in: 0, out: 1 }

  scope :by_ids, ->(ids) { where(id: ids) }

  scope :event_between, ->(start_date, end_date) { where('timestamp >= ? AND timestamp <= ?', start_date, end_date) }

  scope :duplicated, lambda {
    where(id: self.select(
      :id, :employee_id, :kind,
      'events."timestamp",
      case when (
        select count(*)
        from events e2
        where
        e2.id <> events.id and
        e2.employee_id = events.employee_id and
        e2.kind = 0 and (
          (
            e2."timestamp" BETWEEN
            strftime("%Y-%m-%d %H:%M:%f", events."timestamp") and
            strftime("%Y-%m-%d %H:%M:%f", events."timestamp", "+1 second")
          )
      )) > 0 then 1 else 0 end as duplicated'
    ).select { |e| e.duplicated.eql?(1) }.map(&:id))
  }

  scope :problematic, lambda {
    problematics_events = []
    Event.select(
      :id, :employee_id, :kind, 'strftime("%Y-%m-%d", events."timestamp") as event_time'
    )
    .to_a.group_by { |e| e[:event_time] }.as_json
    .map { |_, v| v.group_by { |emp| emp['employee_id'] } }
    .each do |v|
      v.each_value do |events|
        problematics_events.push(events[0]) if v.size.eql?(1)
        if v.size > 1
          events_in = events.sort_by! { |k| k['id'] }
          events_in = events_in.select { |event_in| event_in['kind'].eql?('in') }
          problematics_events.push(
            events_in.to_a.last(events_in.size - events.select { |event_out| event_out['kind'].eql?('out') }.size)
          )
        end
      end
    end
    by_ids(problematics_events.map { |x| x['id'] })
  }

  scope :working_hrs, lambda { |employee_id, from, to|
    working = []
    events = where(employee_id: employee_id)
            .where('events.id NOT IN (?)', problematic.ids + by_ids(duplicated.ids))
            .event_between(from, to)
            .order(:id)
            .as_json
    events_in = events.select { |event| event['kind'].eql?('in') }.sort_by! { |k| k['id'] }
    events_out = events.select { |event| event['kind'].eql?('out') }.sort_by! { |k| k['id'] }
    events_in.each.with_index do |e, ind|
      working.push(
        (
          (
            events_out[ind]['timestamp'].to_time - e['timestamp'].to_time
          ) / 1.hour
        ).round
      )
    end
    working
  }
end

=begin
  
or
          (
            e2."timestamp" BETWEEN
            strftime("%Y-%m-%d %H:%M:%f", events."timestamp", "-1 second") and
            strftime("%Y-%m-%d %H:%M:%f", events."timestamp")
          )
  
=end
