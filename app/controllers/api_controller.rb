require 'import_archive_job'
require 'fileutils'
class ApiController < ApplicationController

  def upload_measure
    @file = params[:file]
    @path = @file.path
    @data = @file.read
    temp_file = Dir.pwd + "/tmp/Measures/" + rand(1000).to_s + ".zip"
    File.open(temp_file,"wb"){ |f| f.write(@data) }
    %x(rake bundle:import[#{temp_file},true,false,'*',false,false])
    File.delete(temp_file)
    render json: {
               action:"Upload Measure"
           }
  end

  def upload_patients
    file = params[:file]
    practice = params[:practice]
    puts practice

    FileUtils.mkdir_p(File.join(Dir.pwd, "tmp/import"))
    file_location = File.join(Dir.pwd, "tmp/import")
    file_name = "patient_upload" + Time.now.to_i.to_s + rand(1000).to_s

    temp_file = File.new(file_location + "/" + file_name, "w")

    File.open(temp_file.path, "wb") { |f| f.write(file.read) }
    #%x(rake import:patients[#{}])
    render json: {
               action:"Upload Patients"
           }
  end

  def upload_provider
    file = params[:file]
    FileUtils.mkdir_p(File.join(Dir.pwd, "tmp/import"))
    file_location = File.join(Dir.pwd, "tmp/import")
    file_name = "provider_upload" + Time.now.to_i.to_s + rand(1000).to_s

    temp_file = File.new(file_location + "/" + file_name, "w")

    File.open(temp_file.path, "wb") { |f| f.write(file.read) }

    provider_tree = ProviderTreeImporter.new(File.open(temp_file))
    provider_tree.load_providers(provider_tree.sub_providers)
    render json: {
               action:"Upload Provider"
           }
  end
end