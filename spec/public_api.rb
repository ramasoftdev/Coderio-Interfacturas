# frozen_string_literal: true

module PublicApi
  def given_event(employee_id: 1, timestamp: Time.zone.now, kind: :in)
    t = to_unix(timestamp)
    post_event(employee_id: employee_id, timestamp: t, kind: kind)
    expect(response.status).to eq(200)
  end

  def post_event(params = {})
    post('/events', params: params)
  end

  def report(employee_id:, from:, to:)
    get_report(employee_id, from, to)
    expect(response.status).to eq(200)
    JSON.parse(response.body).symbolize_keys
  end

  def get_report(employee_id, from, to)
    get("/reports/#{employee_id}/#{from}/#{to}")
  end

  private

  def to_unix(timestamp)
    case timestamp
    when String
      Time.parse(timestamp).to_i
    when Time
      timestamp.to_i
    when Number
      timestamp.to_i
    else
      raise ArgumentError, 'Invalid timestamp type. Only String, Time and Number are supported.'
    end
  end
end
