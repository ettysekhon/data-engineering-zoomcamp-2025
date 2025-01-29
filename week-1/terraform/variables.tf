variable "credentials" {
  description = "My Credentials"
  default     = "./keys/gcp_creds.json"
}

variable "project" {
  description = "Project"
  default     = "de-zoomcamp-414015"
}

variable "region" {
  description = "Region"
  default     = "europe-west2"
}

variable "location" {
  description = "Project Location"
  default     = "europe-west2"
}

variable "storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "de_zoomcamp_414015_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "de_zoomcamp_414015_bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}