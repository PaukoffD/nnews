json.array!(@tagoverlaps) do |tagoverlap|
  json.extract! tagoverlap, :id, :tag_id, :name, :tagtarget_id, :nametarget
  json.url tagoverlap_url(tagoverlap, format: :json)
end
