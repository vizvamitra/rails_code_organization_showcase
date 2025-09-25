ActiveAdmin.register Client do
  config.batch_actions = false

  actions :index, :show

  filter :id
  filter :title
  filter :active
  filter :created_at
  filter :updated_at

  index download_links: false do
    id_column
    column(:title, sortable: true) { |c| link_to c.title, resource_path(c) }
    column :active
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table_for(resource) do
      row :id
      row :title
      row :active
      row :created_at
      row :updated_at
    end

    panel "Users" do
      table_for resource.users.order(:id) do
        column :id
        column :email_address
        column(:recent_sessions) do |user|
          sessions = user.sessions.order(updated_at: :desc).limit(3)
          sessions = [
            Session.new(updated_at: 5.minutes.ago, ip_address: "192.168.0.1"),
            Session.new(updated_at: 10.minutes.ago, ip_address: "192.168.0.1")
          ]

          ul(class: "list-disc") do
            sessions.each { |s| li { "#{s.updated_at}: #{s.ip_address}" } }
          end
        end
        column :created_at
        column :updated_at
      end
    end

    panel "Assets" do
      table_for resource.assets.order(moderated: :desc, title: :asc) do
        column(:id)
        column(:source) { status_tag(_1.source) }
        column(:title) do |asset|
          link_to(asset.title, [:admin, asset], class: "flex items-center gap-2")
        end
        column(:url) { link_to("🔗", _1.url, target: "_blank") }
        column :moderated
        column :access_acquired
        column :created_at
        column :updated_at
        column :actions do |asset|
          if asset.moderated?
            link_to "Pause moderation", [:pause_moderation, :admin, asset], method: :post, data: { confirm: "Are you sure?" }
          else
            link_to "Activate moderation", [:activate_moderation, :admin, asset], method: :post, data: { confirm: "Are you sure?" }
          end
        end
      end
    end
  end
end
