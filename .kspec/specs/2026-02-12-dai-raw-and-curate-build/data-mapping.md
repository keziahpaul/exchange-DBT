# DAI Tables Data Mapping

## Table Schemas and PI Tags

### pxa_batch_tac
- **tac_batch_id** (int8): Unique identifier for the TAC batch record
- **version** (int4): Version number of the batch record
- **status** (varchar(20)): Current processing status of the batch
- **created_date** (timestamp): Timestamp indicating when the batch was created
- **run_date** (timestamp): Timestamp indicating when the batch was executed
- **property_id** (int8): Identifier of the property associated with the batch
- **priority** (int2): Processing priority assigned to the batch
- **rule** (int2): Rule identifier applied during batch processing
- **jurisdiction** (varchar(3)): Jurisdiction code applicable to the batch
- **retries** (int2): Number of retry attempts for batch processing
- **is_settling** (bool): Flag indicating whether the batch is in settling state

### pxa_business_event_outbox
- **business_event_id** (int8): Unique identifier for the business event
- **status** (varchar(30)): Current processing status of the business event
- **event_created_date** (timestamp): Timestamp when the business event was created
- **message** (text): Event payload message content
- **headers** (text): Event message headers and metadata (may contain identifiers)
- **retry_count** (int4): Number of retry attempts for event processing

### pxa_conversations_read_ref
- **conversations_read_ref_id** (int8): Unique identifier for the conversation read reference record
- **conversation_subscriber_id** (int8): Identifier linking a subscriber to a conversation
- **message_id** (int8): Identifier of the message within the conversation
- **read_date** (timestamp): Timestamp indicating when the message was read
- **user_id** (int8): Identifier of the user who read the message

### pxa_correspondences (HIGH PI CONTENT)
- **correspondence_id** (int8): Unique identifier for the correspondence record
- **version** (int4): Record version number
- **acct_stmt_freq** (varchar(333)): Account statement frequency or delivery preference
- **phone_number** (varchar(333)): Phone number associated with an individual [PI_CONTACT_NUMBER]
- **fax_number** (varchar(333)): Fax number associated with an individual [PI_FAX]
- **email_address** (varchar(333)): Email address used for correspondence [PI_EMAIL]
- **general_email_address** (varchar(333)): General email address used for correspondence [PI_EMAIL]
- **address_id** (int8): Identifier linking to an address record that may resolve to an individual [PI_FULL_ADDRESS]
- **dx_address_id** (int8): Identifier linking to a DX address record that may resolve to an individual [PI_FULL_ADDRESS]
- **preference** (varchar(333)): Preference setting for correspondence
- **first_name** (varchar(100)): Individual's first name [PI_NAME]
- **middle_name** (varchar(100)): Individual's middle name [PI_NAME]
- **last_name** (varchar(100)): Individual's last name [PI_NAME]
- **label** (varchar(333)): Free-text label that may contain personal information [PI_FREE_TEXT_FIELD]
- **username** (varchar(333)): Username identifying an individual user [PI_USERID]
- **subscriber_id** (int8): Identifier for the subscriber, potentially identifying an individual

### pxa_document_counterpart
- **document_counterpart_id** (int8): Unique identifier for the document counterpart record
- **document_id** (int8): Identifier of the related document
- **counterpart_json_string** (text): JSON representation of counterpart details (may contain personal information) [PI_FREE_TEXT_FIELD]
- **json_diff** (text): JSON diff showing changes between counterpart versions (may contain personal information) [PI_FREE_TEXT_FIELD]
- **compare_status** (varchar(16)): Status indicating the result of the counterpart comparison
- **eln_counterpart_id** (varchar(50)): External identifier for the counterpart in the ELN system
- **capture_date** (timestamp): Timestamp when the counterpart data was captured
- **counterpart_to_compare** (text): Counterpart content used for comparison (may include personal information)
- **compare_date** (timestamp): Timestamp when the comparison was performed
- **counterpart_to_compare_ref** (varchar(500)): Reference or pointer to counterpart content used for comparison [PI_FREE_TEXT_FIELD]
- **counterpart_json_string_ref** (varchar(500)): Reference to stored counterpart JSON content
- **json_diff_ref** (varchar(500)): Reference to stored JSON diff output

### pxa_line_items_changelog (FINANCIAL DATA)
- **line_item_change_id** (int8): Unique identifier for the line item change record
- **settlement_schedule_id** (int8): Identifier linking to the settlement schedule
- **action** (varchar(25)): Action performed on the line item
- **version** (int4): Version number of the line item change
- **amount** (int8): Monetary amount associated with the line item [PI_SENSITIVE_FINANCIAL]
- **payment_method** (varchar(25)): Method used to process the payment [PI_SENSITIVE_FINANCIAL]
- **account_type** (varchar(512)): Type of bank account used for settlement [PI_SENSITIVE_FINANCIAL]
- **account_bank** (varchar(333)): Name of the financial institution [PI_SENSITIVE_FINANCIAL]
- **account_bsb** (varchar(10)): Bank State Branch (BSB) number [PI_SENSITIVE_FINANCIAL]
- **account_number** (varchar(25)): Bank account number used for settlement [PI_SENSITIVE_FINANCIAL]
- **account_holder** (varchar(512)): Name of the account holder [PI_SENSITIVE_FINANCIAL]
- **settlement_category_name** (varchar(333)): Name of the settlement category
- **settlement_category_id** (int8): Identifier of the settlement category
- **transaction_id** (varchar(18)): Transaction reference identifier
- **first_name** (varchar(333)): Individual's first name [PI_NAME]
- **last_name** (varchar(333)): Individual's last name [PI_NAME]
- **user_name** (varchar(333)): Username identifying the user who performed the action [PI_FULL_NAME]
- **user_id** (int8): System identifier of the user who performed the action
- **log_date** (timestamp): Timestamp when the change was logged
- **settlement_date** (timestamp): Date when the settlement occurred
- **subscriber_id** (int8): Subscriber identifier associated with the change
- **subscriber_type** (varchar(333)): Classification of the subscriber
- **ip_address** (varchar(15)): IP address from which the action was performed

### pxa_lodgement_billing_event
- **lodgement_billing_event_id** (int8): Unique identifier for the lodgement billing event record
- **lodgement_case_id** (int8): Identifier of the related lodgement case
- **fee_type** (varchar(333)): Type/category of fee applied for this lodgement billing event
- **pexa_prod_id** (varchar(100)): Identifier of the PEXA product associated with this billing event
- **jurisdiction** (varchar(333)): Jurisdiction applicable to the lodgement/billing event
- **subs_billing_entity** (int8): Identifier of the subscriber billing entity used for billing attribution
- **workspace_id** (int8): Identifier of the workspace associated with the billing event
- **subs_wspace_id** (varchar(333)): Identifier of the subscriber's workspace context used for billing/attribution
- **lodgement_date** (timestamp): Timestamp when lodgement occurred
- **doc_id** (int8): Identifier of the document associated with the lodgement/billing event
- **settlement_flag** (bool): Flag indicating whether the lodgement is settlement-related
- **title_ref** (varchar(1000)): Land title reference used for lodgement/registry context
- **bundle_type** (varchar(333)): Type of bundle applied to the billing event
- **bundle_subscription** (varchar(100)): Bundle subscription identifier/label used for billing attribution
- **doc_type** (varchar(333)): Document type associated with the lodgement/billing event
- **usage** (varchar(255)): Usage classification applied for billing
- **lr_invoice_ref** (varchar(333)): Land Registry invoice reference identifier for associated fees
- **lr_fee_date** (timestamp): Date/time when the Land Registry fee was applied/recorded
- **lr_fee_ref_num** (varchar(333)): Land Registry fee reference number (external reference)
- **lr_fee_calc_status** (varchar(333)): Status of Land Registry fee calculation for this event
- **lr_fee_type** (varchar(333)): Land Registry fee type/category used to determine billing
- **lr_fee_desc** (varchar(333)): Description/label of the Land Registry fee
- **lr_fee_net** (numeric): Net amount of the Land Registry fee (excluding GST)
- **lr_fee_gst** (numeric): GST component of the Land Registry fee
- **lr_fee_total** (numeric): Total Land Registry fee amount (net + GST)
- **pexa_fee_type** (varchar(333)): PEXA fee type/category applied for this event
- **pexa_fee_desc** (varchar(333)): Description/label of the PEXA fee
- **pexa_fee_net** (numeric): Net amount of the PEXA fee (excluding GST)
- **pexa_fee_gst** (numeric): GST component of the PEXA fee
- **pexa_fee_total** (numeric): Total PEXA fee amount (net + GST)
- **lodgement_fee_status** (varchar(333)): Status of the lodgement fee processing
- **show_flag** (bool): Flag indicating whether the event/fee should be shown
- **multi_usage_flag** (bool): Flag indicating whether multiple usage applies
- **last_updated_date** (timestamp): Timestamp when the record was last updated
- **subscriber_id** (int8): Subscriber identifier associated with the billing event
- **subscriber_role** (varchar(333)): Role of the subscriber in the lodgement context
- **ris_requesting_role** (varchar(40)): Requesting role from RIS context
- **lr_document_id** (varchar(25)): Land Registry document identifier for the lodged document
- **lr_lodgement_ref** (varchar(25)): Land Registry lodgement reference identifier
- **express_refinance** (bool): Flag indicating whether the event relates to express refinance processing

### pxa_residuals
- **document_id** (int8): Identifier of the document associated with the residual record
- **config_data** (text): Configuration data used to control residual processing behaviour
- **config_id** (int8): Identifier of the residual configuration applied to this record
- **stylesheet_version** (int8): Version number of the stylesheet used for residual processing
- **data_values** (text): Residual data values captured during processing which may contain personal information [PI_MULTI]
- **data_values_ref** (varchar(500)): Reference to stored residual data values which may resolve to personal information
- **config_data_ref** (varchar(500)): Reference to stored residual configuration data
- **compliance_data_id** (int8): Identifier linking to associated compliance data

### pxa_simultaneous_lodgements
- **simultaneous_lodgement_id** (int8): Unique identifier for a simultaneous lodgement relationship between workspaces
- **link_type** (varchar(25)): Type of link between workspaces
- **requesting_workspace_id** (int8): Identifier of the workspace initiating the link
- **accepting_workspace_id** (int8): Identifier of the workspace accepting the link
- **requesting_participant** (int8): Identifier of the participant who initiated the request
- **accepting_participant** (int8): Identifier of the participant who accepted the request
- **owner_id** (int8): Identifier of the user who owns the simultaneous lodgement record
- **date_accepted** (timestamp): Timestamp when the link was accepted
- **status** (varchar(25)): Current workflow status of the simultaneous lodgement

### pxa_subscriber_correspondence
- **subscriber_corr_id** (int8): Unique identifier for the subscriber correspondence record
- **subscriber_id** (int8): Subscriber identifier linking correspondence to a subscriber
- **correspondence_id** (int8): Identifier of the related correspondence record
- **jurisdiction** (varchar(3)): Jurisdiction code associated with the correspondence
- **correspondence_type** (varchar(10)): Type of correspondence such as notification, reminder, or alert

### pxa_event_log_type
- **event_log_type_id** (int8): Unique identifier for the event log type
- **description_template** (varchar(333)): Description template used to generate event log messages (may include free-text content)
- **business_event_type_id** (int8): Identifier linking the event log type to a business event type

### pxa_ext_event_sub_mapping
- **map_ext_bus_event_id** (int8): Identifier linking an external business event to a subscriber mapping record
- **map_ext_subscriber_id** (int8): Subscriber identifier used for event-to-subscriber mapping

### pxa_external_business_event
- **ext_bus_event_id** (int8): Unique identifier for the external business event record
- **ext_event_mapping_id** (int8): Identifier linking the external event to its internal mapping
- **java_object_body** (binary): Serialized Java object payload for the external business event (may contain personal information)
- **java_object_class** (varchar(333)): Fully qualified Java class name of the serialized event object
- **for_subscribers** (varchar(333)): List or indicator of subscribers the event is intended for
- **created_date** (timestamp): Timestamp when the external business event was created
- **internal_event_id** (int8): Identifier linking to the internal business event record
- **java_object_body_ref** (varchar(500)): Reference or pointer to the stored Java object payload (may resolve to PI)

### pxa_residual_configs
- **residual_config_id** (int8): Unique identifier for the residual configuration record
- **jurisdiction** (varchar(1500)): Jurisdiction to which the residual configuration applies (e.g. state or registry context)
- **document_category** (varchar(1500)): High-level category used to group document types for residual configuration
- **document_name** (varchar(1500)): Display name of the document associated with the residual configuration
- **sub_category** (varchar(1500)): Sub-category used to further classify the document within the category hierarchy
- **form_name** (varchar(1500)): Name of the form associated with the document/residual configuration
- **document_type** (varchar(1500)): Document type code or label used to determine residual handling
- **usage_description** (varchar(1500)): Description of how the document or configuration is intended to be used within the residual process
- **is_active** (bool): Flag indicating whether the residual configuration is active
- **product_code** (varchar(1500)): Product code used to associate the residual configuration with a specific product
- **json_config** (text): JSON configuration payload defining residual behaviour and rules (configuration data only)

### pxa_simultaneous_workspaces
- **simultaneous_lodgement_id** (int8): Unique identifier linking related workspaces under a simultaneous lodgement grouping
- **workspace_id** (int8): Identifier of a workspace participating in the simultaneous lodgement relationship

## PI Tag Summary
- **PI_CONTACT_NUMBER**: Phone numbers
- **PI_FAX**: Fax numbers  
- **PI_EMAIL**: Email addresses
- **PI_FULL_ADDRESS**: Address identifiers
- **PI_NAME**: Individual names (first, middle, last)
- **PI_FREE_TEXT_FIELD**: Free text fields that may contain PI
- **PI_USERID**: User identifiers
- **PI_SENSITIVE_FINANCIAL**: Financial account information
- **PI_FULL_NAME**: Full name fields
- **PI_MULTI**: Multi-type PI content
