/**
 * API helper — fetches backend data for a given environment.
 *
 * The runtime configuration is loaded from /config.json which Nginx
 * serves from the container. Each environment build injects a different
 * VITE_BACKEND_URL at Docker-build time so the browser uses the correct
 * host-reachable URL (never Docker-internal DNS).
 */

export interface HealthData {
  status: string;
  environment: string;
  timestamp: string;
}

export interface InfoData {
  application: string;
  version: string;
  environment: string;
  service: string;
  description: string;
}

export interface StatusData {
  application: string;
  version: string;
  environment: string;
  service: string;
  status: string;
  uptime_check: string;
  timestamp: string;
  description: string;
  host_info: string;
}

export interface EnvironmentStatus {
  name: string;
  label: string;
  frontendUrl: string;
  backendUrl: string;
  health: HealthData | null;
  info: InfoData | null;
  backendStatus: StatusData | null;
  backendReachable: boolean;
  frontendReachable: boolean;
  loading: boolean;
  error: string | null;
}

/** Static environment definitions — the ports match the Terraform tfvars. */
export const ENVIRONMENTS: { name: string; label: string; frontendPort: number; backendPort: number }[] = [
  { name: 'qa',   label: 'QA',   frontendPort: 8081, backendPort: 8001 },
  { name: 'uat',  label: 'UAT',  frontendPort: 8082, backendPort: 8002 },
  { name: 'prod', label: 'PROD', frontendPort: 8083, backendPort: 8003 },
];

/**
 * Fetch JSON from a URL with a short timeout.
 * Returns null if the request fails (environment not running).
 */
async function safeFetch<T>(url: string, timeoutMs = 4000): Promise<T | null> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, { signal: controller.signal });
    if (!res.ok) return null;
    return (await res.json()) as T;
  } catch {
    return null;
  } finally {
    clearTimeout(timer);
  }
}

/** Check whether a frontend URL is reachable. */
async function checkFrontend(url: string): Promise<boolean> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 3000);
  try {
    const res = await fetch(url, { signal: controller.signal, mode: 'no-cors' });
    // mode: 'no-cors' always gives opaque response — status 0 is expected success
    return res.type === 'opaque' || res.ok;
  } catch {
    return false;
  } finally {
    clearTimeout(timer);
  }
}

/** Probe a single environment and return its status. */
export async function fetchEnvironmentStatus(
  env: typeof ENVIRONMENTS[number]
): Promise<EnvironmentStatus> {
  const host = window.location.hostname || 'localhost';
  const frontendUrl = `http://${host}:${env.frontendPort}`;
  const backendUrl = `http://${host}:${env.backendPort}`;

  const [health, info, backendStatus, frontendReachable] = await Promise.all([
    safeFetch<HealthData>(`${backendUrl}/health`),
    safeFetch<InfoData>(`${backendUrl}/api/info`),
    safeFetch<StatusData>(`${backendUrl}/api/status`),
    checkFrontend(frontendUrl),
  ]);

  return {
    name: env.name,
    label: env.label,
    frontendUrl,
    backendUrl,
    health,
    info,
    backendStatus,
    backendReachable: health !== null,
    frontendReachable,
    loading: false,
    error: null,
  };
}
