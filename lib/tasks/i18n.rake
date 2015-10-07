# Create Date: 2015/10/06
# Author: Hayden Wang
# Input: Name of the file under 'config/locales/**/*.en.yml', can be multiple.
# Output: Duplicate input file into all directory under 'config/locales/**/', or delete as well.
# Usage: Manually create source file in directory 'config/locales/en/', 
#        and excecute rake i18n:build 'YOUR_FILE_NAME' or rake i18n:revert 'YOUR_FILE_NAME'

# /lib/tasks/dev.rake
require 'fileutils'

namespace :i18n do

  locale_list      = %w(cs de es fr hu it nl pl ru th tr zh-TW)
  # locale_list      = %w(cs de)
  source_file_path = 'config/locales/en/'

  # task :build => [:check, :duplicate]

  desc "Check whether the input file exists or not and create it in other locale folders."
  task :build => :environment do
    ARGV.each do |f|
      unless f == 'i18n:build'
        
        task f.to_sym {}
        
        result = File.exist?("#{source_file_path}#{f}.en.yml")
        puts "Check file in #{source_file_path}#{f}.en.yml: #{result}."

        if result

          locale_list.each do |lang|
            other_path = "config/locales/#{lang}/"
            FileUtils.cp "#{source_file_path}#{f}.en.yml", "#{other_path}#{f}.en.yml"

            puts "Duplicate file into #{other_path}#{f}.en.yml: done."
          end

          # Rake::Task["i18n:duplicate"].invoke #invokes i18n:duplicate
        else
          puts 'Target file doesn\'t exist.'
          puts 'Please create the file first.'
          # Rake::Task["i18n:create"].invoke #invokes i18n:duplicate
        end

      end
    end
  end

  desc "Check whether the input file duplicated or not and delete it in other locale folders."
  task :revert => :environment do
    ARGV.each do |f|
      unless f == 'i18n:revert'
        
        task f.to_sym {}

        source_exist = File.exist?("#{source_file_path}#{f}.en.yml")

        unless source_exist
          puts "Source file: #{source_file_path}#{f}.en.yml: doesn\'t exist."
          puts "Mission abort!"
          # raise
          next
        end

        locale_list.each do |lang|
          # puts 'Deleting files.'
          other_path = "config/locales/#{lang}/"
          # FileUtils.cp "#{source_file_path}#{f}.en.yml", "#{other_path}#{f}.en.yml"
          result = File.exist?("#{other_path}#{f}.en.yml")
          # puts "check file in #{other_path}#{f}.en.yml: #{result}."
          if result
            FileUtils.rm "#{other_path}#{f}.en.yml"
            puts "Delete file #{other_path}#{f}.en.yml: done."
          else
            puts "Target file #{other_path}#{f}.en.yml doesn\'t exist: skip."
          end
          
        end

      end
    end
  end

  # desc "Duplicate i18n dictionary to each locale directory."
  # task :duplicate do
  #   puts '123'
  # end

  # desc "Create i18n dictionary to each locale directory."
  # task :create do
  #   puts '456'
  # end

end

