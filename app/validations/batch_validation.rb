BatchFormSchema = Dry::Validation.Schema do
  key(:batch) do |batch|
    batch.hash? do
      optional(:product_id)
      optional(:quantity)
      optional(:completed_on)
      optional(:zone_id).required(:int?)
      optional(:notes).required(:str?)
      optional(:notes)
      optional(:user_ids).each(:int?)
    end
  end
end
