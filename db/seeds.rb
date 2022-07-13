# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

CURRENT_TIME = DateTime.current

EVENTS = [
  {
    employee_id: 1,
    timestamp: CURRENT_TIME,
    kind: :in
  },
  {
    employee_id: 1,
    timestamp: CURRENT_TIME + (0.5).seconds,
    kind: :in
  },
  {
    employee_id: 1,
    timestamp: CURRENT_TIME + 2.hours,
    kind: :out
  },
  {
    employee_id: 1,
    timestamp: CURRENT_TIME + 1.day,
    kind: :in
  },
  {
    employee_id: 1,
    timestamp: CURRENT_TIME + 2.days,
    kind: :in
  },
  {
    employee_id: 1,
    timestamp: CURRENT_TIME + 2.days + 8.hours,
    kind: :out
  },
].freeze

EVENTS.each do |event_attrs|
  Event.find_or_create_by(timestamp: event_attrs[:timestamp]) do |event|
    event.employee_id = event_attrs[:employee_id]
    event.kind = event_attrs[:kind]
  end
end
