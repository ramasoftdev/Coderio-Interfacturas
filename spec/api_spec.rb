# frozen_string_literal: true

require 'rails_helper'
require 'public_api'

RSpec.describe 'public api', type: :request do
  include PublicApi

  let(:first_employee) { 1 }
  let(:second_employee) { 2 }

  it 'generates report based on events' do
    given_event(employee_id: first_employee, timestamp: '2019-05-01 08:00', kind: :in)
    given_event(employee_id: first_employee, timestamp: '2019-05-01 16:00', kind: :out)
    given_event(employee_id: first_employee, timestamp: '2019-05-02 08:00', kind: :in)
    given_event(employee_id: first_employee, timestamp: '2019-05-02 16:00', kind: :out)

    report = report(employee_id: first_employee, from: '2019-05-01', to: '2019-05-30')

    expect(report).to include({
                                employee_id: first_employee,
                                from: '2019-05-01', to: '2019-05-30',
                                working_hrs: 16.0,
                                problematic_dates: []
                              })
  end

  it 'rounds work time to two decimal places' do
    given_event(employee_id: first_employee, timestamp: '2019-05-01 08:10:00:050', kind: :in)
    given_event(employee_id: first_employee, timestamp: '2019-05-01 16:00:01:070', kind: :out)

    report = report(employee_id: first_employee, from: '2019-05-01', to: '2019-05-01')

    expect(report[:working_hrs]).to eq(7.83)
  end

  it 'discovers problematic date when there is no leave event' do
    given_event(employee_id: first_employee, timestamp: '2019-05-01 08:00', kind: :in)
    given_event(employee_id: first_employee, timestamp: '2019-05-02 08:00', kind: :in)
    given_event(employee_id: first_employee, timestamp: '2019-05-02 16:00', kind: :out)

    report = report(employee_id: first_employee, from: '2019-05-01', to: '2019-05-30')

    expect(report).to include({
                                employee_id: first_employee,
                                from: '2019-05-01', to: '2019-05-30',
                                working_hrs: 8.0,
                                problematic_dates: ['2019-05-01']
                              })
  end

  it 'discovers problematic date when there is skip day event' do
    given_event(employee_id: first_employee, timestamp: '2019-05-01 08:00', kind: :in)
    given_event(employee_id: first_employee, timestamp: '2019-05-02 16:00', kind: :out)

    report = report(employee_id: first_employee, from: '2019-05-01', to: '2019-05-30')

    expect(report).to include({
                                employee_id: first_employee,
                                from: '2019-05-01', to: '2019-05-30',
                                working_hrs: 0.0,
                                problematic_dates: ['2019-05-01', '2019-05-02']
                              })
  end
end
