############################### FOLDER SINK #######################################################

resource "google_logging_folder_sink" "app_folder_sink" {
  for_each    = { for x, n in var.folder_sink_config : x => n }
  name        = "${each.value.folder_name}-logsink-${index(var.folder_sink_config, each.value) + 1}"
  description = "Folder sink for ${each.value.folder_name}"
  folder      = each.value.folder_id

  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${each.value.pubsub_topic_name}"

  filter           = each.value.filter
  include_children = true
  depends_on       = [module.app-pubsub]
}

resource "google_pubsub_topic_iam_binding" "app_sink_writer" {
  for_each = { for x, n in google_logging_folder_sink.app_folder_sink : x => n }
  project  = var.project_id
  topic    = element(split("/", each.value.destination), length(split("/", each.value.destination)) - 1)
  role     = "roles/pubsub.publisher"
  members = [
    each.value.writer_identity
  ]
}
resource "google_pubsub_topic_iam_member" "logsink_sa_binding_publisher" {
  for_each = { for x, n in module.app-pubsub : x => n }
  project  = var.project_id
  topic    = each.value.topic
  role     = "roles/pubsub.publisher"
  member   = "serviceAccount:soc-logsink2arcsight-${var.environment}@${var.project_id}.iam.gserviceaccount.com"
}


############################### PROJECT SINK #######################################################

resource "google_logging_project_sink" "app_project_sink" {
  for_each    = { for x, n in var.project_sink_config : x => n }
  name        = "${each.value.project_name}-logsink-${index(var.project_sink_config, each.value) + 1}"
  description = "Project sink for ${each.value.project_name}"
  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${each.value.pubsub_topic_name}"

  filter                 = each.value.filter
  project                = each.value.project_id
  unique_writer_identity = true

}


resource "google_pubsub_topic_iam_binding" "project_sink_writer" {
  for_each = { for x, n in google_logging_project_sink.app_project_sink : x => n }
  project  = var.project_id
  topic    = element(split("/", each.value.destination), length(split("/", each.value.destination)) - 1)
  role     = "roles/pubsub.publisher"
  members = [
    each.value.writer_identity
  ]
}
