module DeviseHelper
  def devise_error_messages!
    return {}.to_json if resource.errors.empty?

    messages = resource.errors.full_messages
    sentence = I18n.t("errors.messages.not_saved",
                count: resource.errors.count,
                resource: resource.class.model_name.human.downcase)

    {
      sentence => messages
    }.to_json
  end
end
