# ---------------------------------------------------------------------------
# providers.tf — Docker provider configuration
# ---------------------------------------------------------------------------

provider "docker" {
  # On Windows with Docker Desktop, the provider connects via the
  # default named pipe. No remote API exposure is needed.
  host = "npipe:////.//pipe//docker_engine"
}
