ActiveAdmin.register Moderation::Asset do
  config.batch_actions = false

  actions :index, :show

  action_item :pause_moderation, only: :show, if: -> { resource.moderated } do
    link_to(
      "Pause moderation",
      [:pause_moderation, :admin, resource],
      method: :post,
      class: "px-3 py-2 bg-red-50 dark:bg-red-800 rounded-lg",
      data: { confirm: "Are you sure?" }
    )
  end

  action_item :activate_moderation, only: :show, if: -> { !resource.moderated } do
    link_to(
      "Activate moderation",
      [:activate_moderation, :admin, resource],
      method: :post,
      class: "px-3 py-2 bg-gray-200 dark:bg-gray-700 rounded-lg",
      data: { confirm: "Are you sure?" }
    )
  end

  filter :id
  filter :public_id_eq, label: "Public Id"
  filter :client_id, label: "Client Id"
  filter :source, as: :select, collection: Moderation::Asset.sources
  filter :title
  filter :moderated
  filter :access_acquired
  filter :created_at
  filter :updated_at

  index download_links: false do
    selectable_column
    id_column
    column(:client, sortable: :client_id)
    column(:source) { status_tag(_1.source) }
    column(:title) do |asset|
      link_to(asset.title, [:admin, asset], class: "flex items-center gap-2")
    end
    column(:url) { link_to("🔗", _1.url, target: "_blank") }
    column :moderated
    column :access_acquired
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table_for(resource) do
      row :id
      row :client
      row(:public_id)
      row(:source) { status_tag(_1.source) }
      row :title
      row(:avatar) { image_tag(_1.avatar_url, size: "64x64", class: "rounded-full") }
      row(:url) { link_to(_1.url, target: "_blank") }
      row :moderated
      row :access_acquired
      row :created_at
      row :updated_at
    end
  end

  member_action :pause_moderation, method: :post do
    Moderation::Interface.new.toggle_asset_moderation(
      client_id: resource.client_id,
      asset_id: resource.id,
      moderated: false
    )
    redirect_to request.referer, notice: "Moderation paused"
  end

  member_action :activate_moderation, method: :post do
    Moderation::Interface.new.toggle_asset_moderation(
      client_id: resource.client_id,
      asset_id: resource.id,
      moderated: true
    )
    redirect_to request.referer, notice: "Moderation activated"
  end
end
