# frozen_string_literal: true

class Report
  include ActiveModel::Validations
  # TODO: represents the actual report, validate data and implement report methods
  def self.get(employee_id, from, to)
    {
      working_hrs: Event.working_hrs(employee_id, from, to),
      problematic_dates: problematics(employee_id, from, to)
    }
  end

  def self.problematics(employee_id, from, to)
    problematics_events =
      Event.problematic.where(employee_id: employee_id).event_between(from, to) +
      Event.duplicated.where(employee_id: employee_id).event_between(from, to)

    problematics_events.map { |e| e.timestamp.strftime('%F') }.uniq
  end
end
