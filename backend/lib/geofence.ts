/**
 * Convertit des degres en radians.
 */
function deg2rad(deg: number): number {
  return deg * (Math.PI / 180);
}

/**
 * Calcule la distance de Haversine (en metres) entre deux coordonnes GPS.
 */
export function getDistanceBetweenPoints(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371000; // Rayon de la Terre en metres
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) *
      Math.cos(deg2rad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c; // Distance en metres
}

/**
 * Trouve la distance minimale (en metres) entre un point et un segment de ligne GPS.
 */
export function getDistancePointToSegment(
  lat: number,
  lng: number,
  latA: number,
  lngA: number,
  latB: number,
  lngB: number
): number {
  const distAB = getDistanceBetweenPoints(latA, lngA, latB, lngB);
  if (distAB === 0) return getDistanceBetweenPoints(lat, lng, latA, lngA);

  // Projection du point sur le segment AB (formule de projection scalaire simplifiee)
  // Utilisation des coordonnees de projection lineaire relative
  const t =
    ((lng - lngA) * (lngB - lngA) + (lat - latA) * (latB - latA)) /
    ((lngB - lngA) * (lngB - lngA) + (latB - latA) * (latB - latA));

  // Borner t entre 0 et 1 pour rester sur le segment
  const clampedT = Math.max(0, Math.min(1, t));

  // Point projete sur le segment
  const projLat = latA + clampedT * (latB - latA);
  const projLng = lngA + clampedT * (lngB - lngA);

  return getDistanceBetweenPoints(lat, lng, projLat, projLng);
}

/**
 * Evalue l'ecart maximal (en metres) entre une position courante et un trace complet d'itineraire (Polyline/GeoJSON).
 */
export function getRouteDeviation(
  lat: number,
  lng: number,
  routeCoordinates: [number, number][] // Liste de [lng, lat]
): number {
  if (routeCoordinates.length < 2) return 0;

  let minDistance = Infinity;

  // Calculer la distance minimale par rapport a tous les segments composant l'itineraire
  for (let i = 0; i < routeCoordinates.length - 1; i++) {
    const [lngA, latA] = routeCoordinates[i];
    const [lngB, latB] = routeCoordinates[i + 1];

    const dist = getDistancePointToSegment(lat, lng, latA, lngA, latB, lngB);
    if (dist < minDistance) {
      minDistance = dist;
    }
  }

  return minDistance;
}
