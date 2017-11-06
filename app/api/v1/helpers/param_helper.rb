module V1::Helpers::ParamHelper
  def permitted_params(p)
    p = declared(p, include_missing: false)
    p.delete :page
    p.delete :per_page
    p
  end

  def get_record(cls, id)
    record = cls.find_by(id: id)
    error!("#{cls.to_s} with ID: #{id} does not exist", 404) if record.nil?
    record
  end

  def get_collection(cls, ids)
    if !ids.nil?
      ids.collect { |id| get_record(cls, id) }
    else
      nil
    end
  end
end
