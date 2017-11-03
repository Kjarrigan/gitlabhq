module Clusters
  class Cluster < ActiveRecord::Base
    include Presentable

    self.table_name = 'clusters'

    APPLICATIONS = {
      Clusters::Applications::Helm::NAME => Clusters::Applications::Helm
    }.freeze

    belongs_to :user

    has_many :cluster_projects, class_name: 'Clusters::Project'
    has_many :projects, through: :cluster_projects, class_name: '::Project'

    # we force autosave to happen when we save `Cluster` model
    has_one :provider_gcp, class_name: 'Clusters::Providers::Gcp', autosave: true

    # We have to ":destroy" it today to ensure that we clean also the Kubernetes Integration
    has_one :platform_kubernetes, class_name: 'Clusters::Platforms::Kubernetes', autosave: true, dependent: :destroy # rubocop:disable Cop/ActiveRecordDependent

    has_one :application_helm, class_name: 'Clusters::Applications::Helm'

    accepts_nested_attributes_for :provider_gcp, update_only: true
    accepts_nested_attributes_for :platform_kubernetes, update_only: true

    validates :name, cluster_name: true
    validate :restrict_modification, on: :update

    delegate :status, to: :provider, allow_nil: true
    delegate :status_reason, to: :provider, allow_nil: true
    delegate :on_creation?, to: :provider, allow_nil: true

    enum platform_type: {
      kubernetes: 1
    }

    enum provider_type: {
      user: 0,
      gcp: 1
    }

    scope :enabled, -> { where(enabled: true) }
    scope :disabled, -> { where(enabled: false) }

    def status_name
      if provider
        provider.status_name
      else
        :created
      end
    end

    def applications
      [
        application_helm || build_application_helm
      ]
    end

    def provider
      return provider_gcp if gcp?
    end

    def platform
      return platform_kubernetes if kubernetes?
    end

    def first_project
      return @first_project if defined?(@first_project)

      @first_project = projects.first
    end
    alias_method :project, :first_project

    def kubeclient
      platform_kubernetes.kubeclient if kubernetes?
    end

    private

    def restrict_modification
      if provider&.on_creation?
        errors.add(:base, "cannot modify during creation")
        return false
      end

      true
    end
  end
end
