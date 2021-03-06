class Service::ContinuityApp < Service
  self.hook_name = :continuity_app

  def receive_push
    http_post "http://hooks.continuityapp.com/github_selfservice/v1/%d" % data['project_id'].to_i,
      :payload => JSON.generate(payload)
  end
end
