# frozen_string_literal: true

class ReportsController < ApplicationController
  # TODO: implement report generation endpoint - it should delegate to ReportGenerator
  def get
    render json: ::Report.get(employee_id, from, to)
  end

  def employee_id
    params[:employee_id]
  end

  def from
    params[:from]
  end

  def to
    params[:to]
  end
end
