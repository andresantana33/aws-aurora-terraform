region = "us-east-1"

db_config = {
  db-postrade-prod = {
      name = "db-postrade-prod",
      engine         = "aurora-postgresql",
      engine_mode = "provisioned",
      engine_version = "16.1",
      instance_class = "db.serverless",
      master_username = "postgres",
      storage_encrypted = true,
      monitoring_interval = "60",
      skip_final_snapshot = "true",
      auto_pause                  = true,
      min_capacity                = "1",  
      max_capacity                = "5", 
      seconds_until_auto_pause    = "300", 
      performance_insights_enabled = true,
      apply_immediately   = true,
                 
   }
  
}
