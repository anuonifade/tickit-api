class HealthController < ActionController::Base
  # GET /healthz
  # Simple health check endpoint for Kubernetes probes
  def healthz
    render json: { status: 'ok', timestamp: Time.now.utc }
  end
end
