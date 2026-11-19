const Map<String, dynamic> validationDemoSchema = {
  'title': 'Validation Engine Demo',
  'type': 'object',
  'layout': {
    'mode': 'tabs',
    'sections': [
      {'id': 'account', 'title': 'Account', 'fields': ['username', 'email', 'age', 'role']},
      {'id': 'validation', 'title': 'Validation', 'fields': ['terms', 'creditCard', 'confirmationCode', 'website', 'contact']},
      {'id': 'nested', 'title': 'Groups and Arrays', 'fields': ['credentials', 'emails', 'selectedFeatures']},
    ],
  },
  'properties': {
    'username': {
      'title': 'Username',
      'type': 'string',
      'widget': 'text',
      'minLength': 4,
      'maxLength': 20,
      'pattern': r'^[a-zA-Z0-9_]+$',
      'x-validators': [
        {
          'type': 'custom',
          'name': 'reservedUsername',
          'message': 'This username is reserved.',
        },
      ],
    },

    'email': {
      'title': 'Email',
      'type': 'string',
      'format': 'email',
      'widget': 'email',
      'x-asyncValidators': [
        {
          'type': 'custom',
          'name': 'uniqueEmail',
          'message': 'This email is already registered.',
        },
      ],
    },

    'age': {
      'title': 'Age',
      'type': 'integer',
      'widget': 'number',
      'minimum': 18,
      'maximum': 65,
    },

    'terms': {
      'title': 'Accept Terms and Conditions',
      'type': 'boolean',
      'widget': 'switch',
      'x-validators': [
        {'type': 'requiredTrue', 'message': 'You must accept the terms.'},
      ],
    },

    'creditCard': {
      'title': 'Credit Card Number',
      'type': 'string',
      'widget': 'text',
      'format': 'credit-card',
      'x-validators': [
        {'type': 'required'},
      ],
    },

    'confirmationCode': {
      'title': 'Confirmation Code',
      'type': 'string',
      'widget': 'text',
      'const': 'OPEN-SESAME',
    },

    'role': {
      'title': 'Role',
      'type': 'string',
      'widget': 'select',
      'enum': ['admin', 'manager', 'user'],
    },

    'website': {
      'title': 'Website URL',
      'type': 'string',
      'widget': 'text',
      'format': 'uri',
      'pattern': r'^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}.*$',
    },

    'contact': {
      'title': 'Email or Phone',
      'type': 'string',
      'widget': 'text',
      'anyOf': [
        {'type': 'string', 'format': 'email'},
        {'type': 'string', 'pattern': r'^\+?[0-9]{10,15}$'},
      ],
    },

    'credentials': {
      'title': 'Credentials',
      'type': 'object',
      'widget': 'group',
      'properties': {
        'password': {
          'title': 'Password',
          'type': 'string',
          'widget': 'password',
          'minLength': 8,
          'pattern': r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$',
        },
        'confirmPassword': {
          'title': 'Confirm Password',
          'type': 'string',
          'widget': 'password',
        },
      },
      'required': ['password', 'confirmPassword'],
      'x-groupValidators': [
        {
          'type': 'mustMatch',
          'control': 'password',
          'matchingControl': 'confirmPassword',
          'message': 'Passwords do not match.',
        },
      ],
    },

    'emails': {
      'title': 'Email Addresses',
      'type': 'array',
      'widget': 'array',
      'minItems': 2,
      'maxItems': 5,
      'uniqueItems': true,
      'items': {'type': 'string', 'format': 'email', 'widget': 'email'},
      'contains': {'const': 'admin@example.com'},
      'x-arrayValidators': [
        {
          'type': 'any',
          'name': 'exampleDomain',
          'message': 'At least one email must use @example.com.',
        },
      ],
    },

    'selectedFeatures': {
      'title': 'Selected Features',
      'type': 'array',
      'widget': 'multiselect',
      'items': {
        'type': 'string',
        'enum': ['flutter', 'postgres', 'fastify'],
      },
      'minItems': 2,
    },
  },

  'required': [
    'username',
    'email',
    'age',
    'terms',
    'creditCard',
    'confirmationCode',
    'role',
    'website',
    'contact',
    'credentials',
    'emails',
    'selectedFeatures',
  ],
};
