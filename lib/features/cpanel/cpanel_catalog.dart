import 'package:flutter/material.dart' hide Theme;

class CpanelMetric {
  const CpanelMetric(this.label, this.endpoint, this.icon);

  final String label;
  final String endpoint;
  final IconData icon;
}

class CpanelFeature {
  const CpanelFeature({
    required this.slug,
    required this.title,
    required this.description,
    required this.endpoint,
    required this.icon,
    this.sensitive = false,
  });

  final String slug;
  final String title;
  final String description;
  final String endpoint;
  final IconData icon;
  final bool sensitive;
}

class CpanelFeatureGroup {
  const CpanelFeatureGroup(this.title, this.features);

  final String title;
  final List<CpanelFeature> features;
}

class CpanelCategory {
  const CpanelCategory({
    required this.slug,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.metrics,
    required this.groups,
  });

  final String slug;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final List<CpanelMetric> metrics;
  final List<CpanelFeatureGroup> groups;

  String get path => '/cpanel/$slug';
  int get featureCount =>
      groups.fold(0, (count, group) => count + group.features.length);
}

const cpanelCategories = <CpanelCategory>[
  CpanelCategory(
    slug: 'accounts-access',
    title: 'Accounts & Access',
    description:
        'Manage control-panel users, roles, and the permissions assigned to each role.',
    icon: Icons.manage_accounts_outlined,
    accent: Color(0xFF167D72),
    metrics: [
      CpanelMetric('Admin users', '/admin_users', Icons.people_outline),
      CpanelMetric('Roles', '/roles', Icons.badge_outlined),
      CpanelMetric(
          'Permission grants', '/role_module_permissions', Icons.lock_outline),
    ],
    groups: [
      CpanelFeatureGroup('People', [
        CpanelFeature(
          slug: 'admin_users',
          title: 'Admin users',
          description: 'View and manage control-panel administrator accounts.',
          endpoint: '/admin_users',
          icon: Icons.people_outline,
        ),
      ]),
      CpanelFeatureGroup('Roles & permissions', [
        CpanelFeature(
          slug: 'roles',
          title: 'Roles',
          description:
              'Define role names, descriptions, and administrator access.',
          endpoint: '/roles',
          icon: Icons.badge_outlined,
        ),
        CpanelFeature(
          slug: 'role_module_permissions',
          title: 'Module permissions',
          description: 'Assign module-level permissions to each role.',
          endpoint: '/role_module_permissions',
          icon: Icons.lock_outline,
        ),
        CpanelFeature(
          slug: 'role_templates',
          title: 'Role templates',
          description: 'Create reusable role configurations.',
          endpoint: '/role_templates',
          icon: Icons.copy_all_outlined,
        ),
        CpanelFeature(
          slug: 'role_template_modules',
          title: 'Template modules',
          description: 'Choose which modules are included in a role template.',
          endpoint: '/role_template_modules',
          icon: Icons.account_tree_outlined,
        ),
      ]),
    ],
  ),
  CpanelCategory(
    slug: 'organizations',
    title: 'Organizations & Tenants',
    description:
        'Set up companies and institutes, connect their domains, and review tenant history.',
    icon: Icons.apartment_outlined,
    accent: Color(0xFF356AC3),
    metrics: [
      CpanelMetric('Institutes', '/institutes', Icons.account_balance_outlined),
      CpanelMetric('Domains', '/institute_domains', Icons.language_outlined),
      CpanelMetric('Tenant plans', '/institute_subscriptions',
          Icons.receipt_long_outlined),
    ],
    groups: [
      CpanelFeatureGroup('Organization directory', [
        CpanelFeature(
            slug: 'cpanel_companies',
            title: 'Companies',
            description: 'Manage control-panel companies.',
            endpoint: '/cpanel_companies',
            icon: Icons.business_outlined),
        CpanelFeature(
            slug: 'institutes',
            title: 'Institutes',
            description:
                'Manage institute tenants and their organization details.',
            endpoint: '/institutes',
            icon: Icons.account_balance_outlined),
      ]),
      CpanelFeatureGroup('Tenant setup', [
        CpanelFeature(
            slug: 'institute_domains',
            title: 'Domains',
            description: 'Manage domains connected to institutes.',
            endpoint: '/institute_domains',
            icon: Icons.language_outlined),
        CpanelFeature(
            slug: 'institute_subscriptions',
            title: 'Institute subscriptions',
            description: 'Review plans assigned to institute tenants.',
            endpoint: '/institute_subscriptions',
            icon: Icons.receipt_long_outlined),
      ]),
      CpanelFeatureGroup('Governance', [
        CpanelFeature(
            slug: 'institute_audit_logs',
            title: 'Institute audit logs',
            description: 'Review recorded institute administration activity.',
            endpoint: '/institute_audit_logs',
            icon: Icons.history_outlined),
      ]),
    ],
  ),
  CpanelCategory(
    slug: 'customers-sales',
    title: 'Customers & Sales',
    description:
        'Keep customer records, follow-up history, documents, and sales ownership together.',
    icon: Icons.groups_2_outlined,
    accent: Color(0xFFBA6A22),
    metrics: [
      CpanelMetric('Customers', '/customers', Icons.people_alt_outlined),
      CpanelMetric(
          'Customer notes', '/customer_notes', Icons.sticky_note_2_outlined),
      CpanelMetric(
          'Sales agents', '/sales_agents', Icons.support_agent_outlined),
    ],
    groups: [
      CpanelFeatureGroup('Customer directory', [
        CpanelFeature(
            slug: 'customers',
            title: 'Customers',
            description: 'View customer profiles and account details.',
            endpoint: '/customers',
            icon: Icons.people_alt_outlined),
        CpanelFeature(
            slug: 'customer_numbers',
            title: 'Customer numbers',
            description: 'Manage customer contact and reference numbers.',
            endpoint: '/customer_numbers',
            icon: Icons.phone_outlined),
        CpanelFeature(
            slug: 'customer_status',
            title: 'Customer statuses',
            description: 'Configure customer lifecycle statuses.',
            endpoint: '/customer_status',
            icon: Icons.flag_outlined),
      ]),
      CpanelFeatureGroup('Customer activity', [
        CpanelFeature(
            slug: 'customer_status_logs',
            title: 'Status history',
            description: 'Review changes to customer status.',
            endpoint: '/customer_status_logs',
            icon: Icons.manage_history_outlined),
        CpanelFeature(
            slug: 'customer_status_time_logs',
            title: 'Status time logs',
            description: 'Review time recorded against customer statuses.',
            endpoint: '/customer_status_time_logs',
            icon: Icons.schedule_outlined),
        CpanelFeature(
            slug: 'customer_notes',
            title: 'Notes',
            description: 'Review and manage customer notes.',
            endpoint: '/customer_notes',
            icon: Icons.sticky_note_2_outlined),
      ]),
      CpanelFeatureGroup('Customer resources', [
        CpanelFeature(
            slug: 'customer_documents',
            title: 'Documents',
            description: 'Manage files associated with customers.',
            endpoint: '/customer_documents',
            icon: Icons.folder_open_outlined),
        CpanelFeature(
            slug: 'customer_discounts',
            title: 'Discounts',
            description: 'Review customer discount assignments.',
            endpoint: '/customer_discounts',
            icon: Icons.discount_outlined),
        CpanelFeature(
            slug: 'customer_export_templates',
            title: 'Export templates',
            description: 'Configure reusable customer export layouts.',
            endpoint: '/customer_export_templates',
            icon: Icons.file_download_outlined),
        CpanelFeature(
            slug: 'customer_export_templates_fields',
            title: 'Export fields',
            description: 'Choose fields included in customer exports.',
            endpoint: '/customer_export_templates_fields',
            icon: Icons.view_column_outlined),
      ]),
      CpanelFeatureGroup('Sales team', [
        CpanelFeature(
            slug: 'sales_agents',
            title: 'Sales agents',
            description: 'Manage sales representatives and ownership.',
            endpoint: '/sales_agents',
            icon: Icons.support_agent_outlined),
      ]),
    ],
  ),
  CpanelCategory(
    slug: 'packages-entitlements',
    title: 'Packages & Entitlements',
    description:
        'Build plans, configure included features, and control subscription access.',
    icon: Icons.inventory_2_outlined,
    accent: Color(0xFF7356A4),
    metrics: [
      CpanelMetric('Packages', '/packages', Icons.inventory_2_outlined),
      CpanelMetric('Subscriptions', '/subs', Icons.autorenew_outlined),
      CpanelMetric('Package roles', '/package_roles',
          Icons.admin_panel_settings_outlined),
    ],
    groups: [
      CpanelFeatureGroup('Plans & packages', [
        CpanelFeature(
            slug: 'subscription_plans',
            title: 'Subscription plans',
            description: 'Configure available billing plans.',
            endpoint: '/subscription_plans',
            icon: Icons.price_change_outlined),
        CpanelFeature(
            slug: 'packages',
            title: 'Packages',
            description: 'Manage package pricing, limits, and availability.',
            endpoint: '/packages',
            icon: Icons.inventory_2_outlined),
        CpanelFeature(
            slug: 'subs',
            title: 'Subscriptions',
            description: 'Review active and historical subscriptions.',
            endpoint: '/subs',
            icon: Icons.autorenew_outlined),
        CpanelFeature(
            slug: 'sub_packages',
            title: 'Subscription packages',
            description: 'Manage packages assigned to subscriptions.',
            endpoint: '/sub_packages',
            icon: Icons.all_inbox_outlined),
        CpanelFeature(
            slug: 'sub_package_user_tiers',
            title: 'User tiers',
            description: 'Configure user tiers for subscription packages.',
            endpoint: '/sub_package_user_tiers',
            icon: Icons.stacked_bar_chart_outlined),
        CpanelFeature(
            slug: 'sub_modules',
            title: 'Subscription modules',
            description: 'Assign product modules to subscriptions.',
            endpoint: '/sub_modules',
            icon: Icons.extension_outlined),
      ]),
      CpanelFeatureGroup('Feature catalog', [
        CpanelFeature(
            slug: 'package_features',
            title: 'Package features',
            description: 'Choose and price features included in packages.',
            endpoint: '/package_features',
            icon: Icons.extension_outlined),
        CpanelFeature(
            slug: 'package_feature_blocks',
            title: 'Feature blocks',
            description: 'Group package feature settings into sections.',
            endpoint: '/package_feature_blocks',
            icon: Icons.view_agenda_outlined),
        CpanelFeature(
            slug: 'package_feature_block_fields',
            title: 'Feature block fields',
            description: 'Configure fields within package feature blocks.',
            endpoint: '/package_feature_block_fields',
            icon: Icons.view_column_outlined),
        CpanelFeature(
            slug: 'feature_fields',
            title: 'Feature fields',
            description: 'Manage reusable fields for product features.',
            endpoint: '/feature_fields',
            icon: Icons.tune_outlined),
        CpanelFeature(
            slug: 'sub_package_features',
            title: 'Subscription features',
            description: 'Configure features on subscription packages.',
            endpoint: '/sub_package_features',
            icon: Icons.extension_outlined),
        CpanelFeature(
            slug: 'sub_package_feature_blocks',
            title: 'Subscription feature blocks',
            description: 'Group subscription feature settings.',
            endpoint: '/sub_package_feature_blocks',
            icon: Icons.view_agenda_outlined),
        CpanelFeature(
            slug: 'sub_package_feature_block_fields',
            title: 'Subscription feature fields',
            description: 'Configure fields for subscription feature blocks.',
            endpoint: '/sub_package_feature_block_fields',
            icon: Icons.view_column_outlined),
      ]),
      CpanelFeatureGroup('Package access', [
        CpanelFeature(
            slug: 'package_roles',
            title: 'Package roles',
            description: 'Define roles available within a package.',
            endpoint: '/package_roles',
            icon: Icons.badge_outlined),
        CpanelFeature(
            slug: 'package_role_mappings',
            title: 'Role mappings',
            description: 'Map package roles to subscription users.',
            endpoint: '/package_role_mappings',
            icon: Icons.account_tree_outlined),
        CpanelFeature(
            slug: 'package_role_feature_permissions',
            title: 'Feature permissions',
            description: 'Set feature access for mapped package roles.',
            endpoint: '/package_role_feature_permissions',
            icon: Icons.lock_outline),
      ]),
    ],
  ),
  CpanelCategory(
    slug: 'industry-system-setup',
    title: 'Industry & System Setup',
    description:
        'Configure industry-specific modules, environments, templates, and reference data.',
    icon: Icons.tune_outlined,
    accent: Color(0xFF3C758A),
    metrics: [
      CpanelMetric('Industries', '/industries', Icons.factory_outlined),
      CpanelMetric('Environments', '/environments', Icons.cloud_outlined),
      CpanelMetric('Email template groups', '/email_template_modules',
          Icons.mark_email_unread_outlined),
    ],
    groups: [
      CpanelFeatureGroup('Industry configuration', [
        CpanelFeature(
            slug: 'industries',
            title: 'Industries',
            description:
                'Manage industry definitions used by packages and tenants.',
            endpoint: '/industries',
            icon: Icons.factory_outlined),
        CpanelFeature(
            slug: 'industry_environments',
            title: 'Industry environments',
            description: 'Associate environments with supported industries.',
            endpoint: '/industry_environments',
            icon: Icons.hub_outlined),
        CpanelFeature(
            slug: 'industry_modules',
            title: 'Industry modules',
            description: 'Configure modules available for each industry.',
            endpoint: '/industry_modules',
            icon: Icons.extension_outlined),
        CpanelFeature(
            slug: 'environments',
            title: 'Environments',
            description: 'Manage deployment and operating environments.',
            endpoint: '/environments',
            icon: Icons.cloud_outlined),
      ]),
      CpanelFeatureGroup('Reference data & messaging', [
        CpanelFeature(
            slug: 'document_types',
            title: 'Document types',
            description: 'Configure supported document classifications.',
            endpoint: '/document_types',
            icon: Icons.description_outlined),
        CpanelFeature(
            slug: 'email_template_modules',
            title: 'Email template groups',
            description: 'Organize email templates by module.',
            endpoint: '/email_template_modules',
            icon: Icons.mark_email_unread_outlined),
        CpanelFeature(
            slug: 'email_template_fields',
            title: 'Email template fields',
            description: 'Configure fields available to email templates.',
            endpoint: '/email_template_fields',
            icon: Icons.alternate_email_outlined),
      ]),
      CpanelFeatureGroup('Security', [
        CpanelFeature(
            slug: 'master_credentials',
            title: 'Master credentials',
            description:
                'Sensitive credentials are not displayed in the generic module view.',
            endpoint: '/master_credentials',
            icon: Icons.key_outlined,
            sensitive: true),
      ]),
    ],
  ),
  CpanelCategory(
    slug: 'service-desk',
    title: 'Service Desk',
    description:
        'Track service requests, manage ticket types, and review communication history.',
    icon: Icons.support_agent_outlined,
    accent: Color(0xFFB4515C),
    metrics: [
      CpanelMetric(
          'Tickets', '/service_tickets', Icons.confirmation_number_outlined),
      CpanelMetric(
          'Ticket types', '/service_ticket_types', Icons.category_outlined),
      CpanelMetric(
          'Ticket comments', '/service_ticket_comments', Icons.forum_outlined),
    ],
    groups: [
      CpanelFeatureGroup('Ticket management', [
        CpanelFeature(
            slug: 'service_tickets',
            title: 'Tickets',
            description: 'Review and manage customer service requests.',
            endpoint: '/service_tickets',
            icon: Icons.confirmation_number_outlined),
        CpanelFeature(
            slug: 'service_ticket_types',
            title: 'Ticket types',
            description: 'Configure service request categories.',
            endpoint: '/service_ticket_types',
            icon: Icons.category_outlined),
        CpanelFeature(
            slug: 'service_ticket_type_logs',
            title: 'Type history',
            description: 'Review changes to ticket type configuration.',
            endpoint: '/service_ticket_type_logs',
            icon: Icons.history_outlined),
      ]),
      CpanelFeatureGroup('Ticket activity', [
        CpanelFeature(
            slug: 'service_ticket_comments',
            title: 'Comments',
            description: 'Review ticket conversation entries.',
            endpoint: '/service_ticket_comments',
            icon: Icons.forum_outlined),
        CpanelFeature(
            slug: 'service_ticket_logs',
            title: 'Ticket history',
            description: 'Review ticket status and assignment changes.',
            endpoint: '/service_ticket_logs',
            icon: Icons.manage_history_outlined),
        CpanelFeature(
            slug: 'service_ticket_user_contents',
            title: 'User content',
            description: 'Review content submitted by ticket users.',
            endpoint: '/service_ticket_user_contents',
            icon: Icons.chat_bubble_outline),
      ]),
    ],
  ),
  CpanelCategory(
    slug: 'platform-routing',
    title: 'Platform Routing & Provisioning',
    description:
        'Manage registered platform endpoints, site provisioning, and migration records.',
    icon: Icons.account_tree_outlined,
    accent: Color(0xFF506477),
    metrics: [
      CpanelMetric(
          'Control panels', '/cpanels', Icons.dashboard_customize_outlined),
      CpanelMetric('Sites', '/sites', Icons.language_outlined),
      CpanelMetric('Migrations', '/migration_details', Icons.sync_alt_outlined),
    ],
    groups: [
      CpanelFeatureGroup('Platform registry', [
        CpanelFeature(
            slug: 'cpanels',
            title: 'Control panels',
            description: 'Manage registered control-panel instances.',
            endpoint: '/cpanels',
            icon: Icons.dashboard_customize_outlined),
        CpanelFeature(
            slug: 'crms',
            title: 'CRM instances',
            description: 'Manage registered CRM services.',
            endpoint: '/crms',
            icon: Icons.hub_outlined),
        CpanelFeature(
            slug: 'sites',
            title: 'Sites',
            description: 'Review provisioned sites and their routing details.',
            endpoint: '/sites',
            icon: Icons.language_outlined),
      ]),
      CpanelFeatureGroup('Provisioning & secrets', [
        CpanelFeature(
            slug: 'skeleton_details',
            title: 'Site templates',
            description:
                'Manage skeleton configurations used for provisioning.',
            endpoint: '/skeleton_details',
            icon: Icons.web_asset_outlined),
        CpanelFeature(
            slug: 'migration_details',
            title: 'Migrations',
            description: 'Review platform migration records.',
            endpoint: '/migration_details',
            icon: Icons.sync_alt_outlined),
        CpanelFeature(
            slug: 'master_passwords',
            title: 'Router passwords',
            description:
                'Sensitive passwords are not displayed in the generic module view.',
            endpoint: '/master_passwords',
            icon: Icons.password_outlined,
            sensitive: true),
      ]),
    ],
  ),
];

CpanelCategory? cpanelCategoryFor(String slug) {
  for (final category in cpanelCategories) {
    if (category.slug == slug) return category;
  }
  return null;
}

CpanelFeature? cpanelFeatureFor(String slug) {
  for (final category in cpanelCategories) {
    for (final group in category.groups) {
      for (final feature in group.features) {
        if (feature.slug == slug) return feature;
      }
    }
  }
  return null;
}
