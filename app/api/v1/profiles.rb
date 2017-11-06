require_relative './validators/valid_user'
require_relative './validators/length'

module V1
  class Profiles < Grape::API
    helpers do
      def profile_update_permissions
        authenticated_user
        @profile = current_user.profile || Profile.new({user: current_user})
      end

      def profile_destroy_permissions
        profile_update_permissions
      end

      def profile_create
        authenticated_user
        if current_user.profile.nil?
          @profile = Profile.new
          @profile.user = current_user
        else
          @profile = current_user.profile
        end
      end

      def create_entity(cls, params)
        ent = cls.create!(params.merge({ :profile => @profile }))
        ent
      end

      def entity_align(entity, profile)
        error!("401 That #{entity.class} does not belong to the profile", 401) unless profile == entity.profile
      end
    end

    namespace :interests do
      desc "Creates a new interest for a profile.", entity: Entities::Profile::InterestData::AsNested
      params do
        requires :title, type: String, length: 1000, allow_blank: false, desc: "The title of a new interest."
      end
      post do
        profile_create
        ent = create_entity(Interest, {title: params[:title]})
        @profile.save!
        present ent, with: Entities::Profile::InterestData::AsNested
      end

      desc "Updates an existing interest.", entity: Entities::Profile::InterestData::AsNested
      params do
        requires :id, type: Integer, allow_blank: false, desc: "The ID of the interest."
        requires :title, type: String, length: 1000, allow_blank: false, desc: "The new title of the interest."
      end
      put ":id" do
        profile_update_permissions
        interest = get_record(Interest, params[:id])
        entity_align(interest, @profile)
        interest.title = params[:title]
        @profile.save!
        interest.save!
        present interest, with: Entities::Profile::InterestData::AsNested
      end

      desc "Destroy an existing interest."
      params do
        requires :id, type: Integer, allow_blank: false, desc: "The ID of the interest."
      end
      delete ":id" do
        profile_destroy_permissions
        interest = get_record(Interest, params[:id])
        entity_align(interest, @profile)
        interest.destroy!
        status 204
      end
    end


    namespace :locations do
      desc "Creates a new location for a profile.", entity: Entities::Profile::LocationData::AsNested
      params do
        requires :geo_string, type: String, length: 1000, allow_blank: false, desc: "The location string for a location."
      end
      post do
        profile_create
        location = @profile.location || Location.new
        location.geo_string = params[:geo_string]
        location.profile = @profile
        location.save!
        present location, with: Entities::Profile::LocationData::AsNested
      end

      desc "Updates an existing location.", entity: Entities::Profile::LocationData::AsNested
      params do
        requires :id, type: Integer, allow_blank: false, desc: "The ID of the location."
        requires :geo_string, type: String, length: 1000, allow_blank: false, desc: "The new location string of the location."
      end
      put ":id" do
        profile_update_permissions
        location = get_record(Location, params[:location_id])
        entity_align(location, @profile)
        location.geo_string = params[:geo_string]
        @profile.save!
        location.save!
        present location, with: Entities::Profile::LocationData::AsNested
      end

      desc "Destroy an existing location."
      delete do
        profile_destroy_permissions
        if @profile.location.nil?
          error!("There is no location on this profile.", 404)
        end
        @profile.location.destroy!
        status 204
      end
    end


    namespace :positions do
      desc "Creates a new position for a profile.", entity: Entities::Profile::PositionData::AsNested
      params do
        requires :title, type: String, length: 1000, allow_blank: false, desc: "The title of a new position."
        requires :company, type: String, length: 1000, allow_blank: false, desc: "The company of a new position."
      end
      post do
        profile_create
        ent = create_entity(Position, {title: params[:title], company: params[:company]})
        @profile.save!
        present ent, with: Entities::Profile::PositionData::AsNested
      end

      desc "Updates an existing position.", entity: Entities::Profile::PositionData::AsNested
      params do
        requires :id, type: Integer, allow_blank: false, desc: "The ID of the position."
        requires :title, type: String, length: 1000, allow_blank: false, desc: "The new title of the position."
      end
      put ":id" do
        profile_update_permissions
        position = get_record(Position, params[:id])
        entity_align(position, @profile)
        position.title = params[:title]
        @profile.save!
        position.save!
        present position, with: Entities::Profile::PositionData::AsNested
      end

      desc "Destroy an existing position."
      params do
        requires :id, type: Integer, allow_blank: false, desc: "The ID of the position."
      end
      delete ":id" do
        profile_destroy_permissions
        position = get_record(Position, params[:id])
        entity_align(position, @profile)
        position.destroy!
        status 204
      end
    end


    namespace :schools do
      desc "Creates a new school info for a profile.", entity: Entities::Profile::SchoolInfoData::AsNested
      params do
        requires :school_name, type: String, length: 1000, allow_blank: false, desc: "The school name of a new school info."
        requires :grad_year, type: String, length: 1000, allow_blank: false, desc: "The graduation year of a new school info."
        optional :field, type: String, length: 1000, allow_blank: false, desc: "The field of study of a new school info."
      end
      post do
        profile_create
        ent = create_entity(SchoolInfo, {school_name: params[:school_name], grad_year: params[:grad_year], field: params[:field]})
        @profile.save!
        present ent, with: Entities::Profile::SchoolInfoData::AsNested
      end

      desc "Updates an existing school info.", entity: Entities::Profile::SchoolInfoData::AsNested
      params do
        requires :id, type: Integer, allow_blank: false, desc: "The ID of the position."
        optional :school_name, type: String, length: 1000, allow_blank: false, desc: "The school name of a school info."
        optional :grad_year, type: String, length: 1000, allow_blank: false, desc: "The graduation year of a school info."
        optional :field, type: String, length: 1000, allow_blank: false, desc: "The field of study of a school info."
        at_least_one_of :school_name, :grad_year, :field
      end
      put ":id" do
        profile_update_permissions
        si = get_record(SchoolInfo, params[:id])
        entity_align(si, @profile)
        si.update!({
          school_name: params[:school_name] || si.school_name,
          grad_year: params[:grad_year] || si.grad_yaer,
          field: params[:field] || si.field,
        })
        @profile.save!
        si.save!
        present si, with: Entities::Profile::SchoolInfoData::AsNested
      end

      desc "Destroy an existing school info."
      params do
        requires :id, type: Integer, allow_blank: false, desc: "The ID of the school info."
      end
      delete ":id" do
        profile_destroy_permissions
        si = get_record(SchoolInfo, params[:id])
        entity_align(si, @profile)
        si.destroy!
        status 204
      end
    end


    desc "Create a new profile or subentity for a user.", entity: Entities::ProfileData::AsFull
    params do
      optional :interest_title, type: String, length: 1000, allow_blank: false, desc: "The title of a new interest."
      optional :location_string, type: String, length: 1000, allow_blank: false, desc: "The location string of a new location."
      optional :position_title, type: String, length: 1000, allow_blank: false, desc: "The title of a new position."
      optional :position_company, type: String, length: 1000, allow_blank: false, desc: "The company of a new position."
      optional :school_info_school_name, type: String, length: 1000, allow_blank: false, desc: "The school name of a new school info."
      optional :school_info_grad_year, type: String, length: 1000, allow_blank: false, desc: "The grad year of a new school info."
      optional :school_info_field, type: String, length: 1000, allow_blank: false, desc: "The field of a new school info."
      all_or_none_of :position_title, :position_company
      all_or_none_of :school_info_school_name, :school_info_grad_year
    end
    post do
      profile_create
      if params[:location_string]
        location = @profile.location || Location.new
        location.profile = @profile
        location.geo_string = params[:location_string]
        @profile.save!
        location.save!
      end

      if params[:interest_title]
        create_entity(Interest, {title: params[:interest_title]})
      end

      if params[:position_title]
        create_entity(Position, {title: params[:position_title], company: params[:position_company]})
      end

      if params[:school_info_school_name]
        create_entity(SchoolInfo, {school_name: params[:school_info_school_name],
                                   grad_year: params[:school_info_grad_year],
                                   field: params[:school_info_field]})
      end

      if @profile.id.nil?
        @profile.save
      end

      present @profile, with: Entities::ProfileData::AsFull
    end


    desc "Deletes your profile."
    delete do
      profile_destroy_permissions
      @profile.destroy!
      status 204
    end
  end
end
