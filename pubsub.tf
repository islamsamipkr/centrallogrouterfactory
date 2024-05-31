module "app-pubsub" {
  source   = "terraform-google-modules/pubsub/google"
  version  = "~> 5.0"
  for_each = { for x, n in var.pubsub_config : x => n }

  project_id = var.project_id

  # NOTE: Confirmed with Google this only applies to push subscriptions and is not needed in our case.
  #       Not much documentation on this variable and its use. See this PR for details:
  #       https://github.com/terraform-google-modules/terraform-google-pubsub/pull/37
  grant_token_creator = false

  topic               = each.value.pubsub_topic_name
  topic_labels        = each.value.pubsub_topic_labels
  subscription_labels = each.value.subscription_labels

  # NOTE: Google docs say: Assign Subscriber role: The Cloud Pub/Sub service account for this project needs the
  #       subscriber role to forward messages from this subscription to the dead letter topic. This is done
  #       automatically by the module for all subscriptions here:
  #
  #       https://github.com/terraform-google-modules/terraform-google-pubsub/blob/v5.0.0/main.tf#L82
  pull_subscriptions = [
    {

      name = each.value.pubsub_subscription_name

      message_retention_duration = "604800s" // Default (7 days)
      retain_acked_messages      = false     // Default
      ack_deadline_seconds       = 10        // Default
      expiration_policy          = ""        // Subscription never expires

      # NOTE: Cannot use implicit dependency here since dead_letter_topic is used as a key in a for_each in the module
      #
      # NOTE: Google docs say: Assign Publisher role: The Cloud Pub/Sub service account for this project needs the
      #       publisher role to publish dead-lettered messages to the dead letter topic. This is done automatically
      #       by the module when dead_letter_topic is set here:
      #
      #       https://github.com/terraform-google-modules/terraform-google-pubsub/blob/v5.0.0/main.tf#L58
      dead_letter_topic     = "projects/${var.project_id}/topics/${each.value.pubsub_subscription_name}_dl"
      max_delivery_attempts = 5      // Default
      minimum_backoff       = "10s"  // Default
      maximum_backoff       = "600s" // Default

      enable_message_ordering      = true
      enable_exactly_once_delivery = true

      service_account = var.pubsub_subscription_sa
    }
  ]

  depends_on = [
    module.pubsub_dl
  ]
}
