class Api::Healthy::StatusController < ApplicationController

  def show
    render :json => {'message' => 'OK', "version" => "#{Version['version']} #{Version['suffix']}"}, status: 200
  end

end
