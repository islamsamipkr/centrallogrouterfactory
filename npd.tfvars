pubsub_config = [
  {
    pubsub_topic_name = "app_notifications"

]
#===========Pubsub Subscription Service Account===========#
pubsub_subscription_sa = "ssas"
#===========Folder Sink Configuration Details(Folder ID,Name,pubsubtopic name, other configs)=========#

folder_sink_config = [
#==========='mobility-nonprod' folder=========#
  {
    folder_id         = "110188140123132800"
    folder_name       = "folderexample"
    pubsub_topic_name = "pubsubtopic"
    filter            = "severity>=\"WARNING\""
  },
{
    project_id        = "asdad"
    project_name      = "dasd"
    pubsub_topic_name = "pubsubtopic"
    filter            = "severity>=\"WARNING\""
  },
