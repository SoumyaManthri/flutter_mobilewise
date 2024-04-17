import 'dart:math';

import 'package:latlong2/latlong.dart';

import 'math_util.dart';

class MapUtil {
  static bool isLocationOnPath(
      LatLng point, List<LatLng> polyline, bool geodesic,
      {num tolerance = 5}) =>
      _isLocationOnEdgeOrPath(point, polyline, false, geodesic, tolerance);

  static bool _isLocationOnEdgeOrPath(LatLng point, List<LatLng> poly,
      bool closed, bool geodesic, num toleranceEarth) {
    final idx = locationIndexOnEdgeOrPath(
        point, poly, closed, geodesic, toleranceEarth);

    return idx >= 0;
  }

  static int locationIndexOnEdgeOrPath(LatLng point, List<LatLng> poly,
      bool closed, bool geodesic, num toleranceEarth) {
    if (poly.isEmpty) {
      return -1;
    }
    final tolerance = toleranceEarth / earthRadius;
    final havTolerance = MathUtil.hav(tolerance);
    final lat3 = MathUtil.toRadians(point.latitude);
    final lng3 = MathUtil.toRadians(point.longitude);
    final prev = closed ? poly.last : poly.first;
    var lat1 = MathUtil.toRadians(prev.latitude);
    var lng1 = MathUtil.toRadians(prev.longitude);
    var idx = 0;
    if (geodesic) {
      for (final point2 in poly) {
        final lat2 = MathUtil.toRadians(point2.latitude);
        final lng2 = MathUtil.toRadians(point2.longitude);
        if (_isOnSegmentGC(lat1, lng1, lat2, lng2, lat3, lng3, havTolerance)) {
          return max(0, idx - 1);
        }
        lat1 = lat2;
        lng1 = lng2;
        idx++;
      }
    } else {
      // We project the points to mercator space, where the Rhumb segment is a
      // straight line, and compute the geodesic distance between point3 and the
      // closest point on the segment. This method is an approximation, because
      // it uses "closest" in mercator space which is not "closest" on the
      // sphere -- but the error is small because "tolerance" is small.
      final minAcceptable = lat3 - tolerance;
      final maxAcceptable = lat3 + tolerance;
      var y1 = MathUtil.mercator(lat1);
      final y3 = MathUtil.mercator(lat3);
      final xTry = List<num?>.generate(3, (index) => null);

      for (final point2 in poly) {
        final lat2 = MathUtil.toRadians(point2.latitude);
        final y2 = MathUtil.mercator(lat2);
        final lng2 = MathUtil.toRadians(point2.longitude);
        if (max(lat1, lat2) >= minAcceptable &&
            min(lat1, lat2) <= maxAcceptable) {
          // We offset longitudes by -lng1; the implicit x1 is 0.
          final x2 = MathUtil.wrap(lng2 - lng1, -pi, pi);
          final x3Base = MathUtil.wrap(lng3 - lng1, -pi, pi);
          xTry[0] = x3Base;
          // Also explore MathUtil.wrapping of x3Base around the world in both
          // directions.
          xTry[1] = x3Base + 2 * pi;
          xTry[2] = x3Base - 2 * pi;
          for (final x3 in xTry) {
            final dy = y2 - y1;
            final len2 = x2 * x2 + dy * dy;
            final t = len2 <= 0
                ? 0
                : MathUtil.clamp((x3! * x2 + (y3 - y1) * dy) / len2, 0, 1);
            final xClosest = t * x2;
            final yClosest = y1 + t * dy;
            final latClosest = MathUtil.inverseMercator(yClosest);
            final havDist =
            MathUtil.havDistance(lat3, latClosest, x3! - xClosest);
            if (havDist < havTolerance) {
              return max(0, idx - 1);
            }
          }
        }
        lat1 = lat2;
        lng1 = lng2;
        y1 = y2;
        idx++;
      }
    }
    return -1;
  }

  static bool _isOnSegmentGC(num lat1, num lng1, num lat2, num lng2, num lat3,
      num lng3, num havTolerance) {
    final havDist13 = MathUtil.havDistance(lat1, lat3, lng1 - lng3);
    if (havDist13 <= havTolerance) {
      return true;
    }
    final havDist23 = MathUtil.havDistance(lat2, lat3, lng2 - lng3);
    if (havDist23 <= havTolerance) {
      return true;
    }
    final sinBearing = _sinDeltaBearing(lat1, lng1, lat2, lng2, lat3, lng3);
    final sinDist13 = MathUtil.sinFromHav(havDist13);
    final havCrossTrack = MathUtil.havFromSin(sinDist13 * sinBearing);
    if (havCrossTrack > havTolerance) {
      return false;
    }
    final havDist12 = MathUtil.havDistance(lat1, lat2, lng1 - lng2);
    final term = havDist12 + havCrossTrack * (1 - 2 * havDist12);
    if (havDist13 > term || havDist23 > term) {
      return false;
    }
    if (havDist12 < 0.74) {
      return true;
    }
    final cosCrossTrack = 1 - 2 * havCrossTrack;
    final havAlongTrack13 = (havDist13 - havCrossTrack) / cosCrossTrack;
    final havAlongTrack23 = (havDist23 - havCrossTrack) / cosCrossTrack;
    final sinSumAlongTrack =
    MathUtil.sinSumFromHav(havAlongTrack13, havAlongTrack23);
    return sinSumAlongTrack >
        0; // Compare with half-circle == pi using sign of sin().
  }

  static num _sinDeltaBearing(
      num lat1, num lng1, num lat2, num lng2, num lat3, num lng3) {
    final sinLat1 = sin(lat1);
    final cosLat2 = cos(lat2);
    final cosLat3 = cos(lat3);
    final lat31 = lat3 - lat1;
    final lng31 = lng3 - lng1;
    final lat21 = lat2 - lat1;
    final lng21 = lng2 - lng1;
    final a = sin(lng31) * cosLat3;
    final c = sin(lng21) * cosLat2;
    final b = sin(lat31) + 2 * sinLat1 * cosLat3 * MathUtil.hav(lng31);
    final d = sin(lat21) + 2 * sinLat1 * cosLat2 * MathUtil.hav(lng21);
    final denom = (a * a + b * b) * (c * c + d * d);
    return denom <= 0 ? 1 : (a * d - b * c) / sqrt(denom);
  }

  //POLYGON
  static bool containsLocation(
      LatLng point, List<LatLng> polygon, bool geodesic) =>
      containsLocationAtLatLng(
          point.latitude, point.longitude, polygon, geodesic);

  static bool containsLocationAtLatLng(
      num latitude, num longitude, List<LatLng> polygon, bool geodesic) {
    if (polygon.isEmpty) {
      return false;
    }

    final lat3 = MathUtil.toRadians(latitude);
    final lng3 = MathUtil.toRadians(longitude);
    final prev = polygon.last;
    var lat1 = MathUtil.toRadians(prev.latitude);
    var lng1 = MathUtil.toRadians(prev.longitude);
    var nIntersect = 0;

    for (final point2 in polygon) {
      final dLng3 = MathUtil.wrap(lng3 - lng1, -pi, pi);
      // Special case: point equal to vertex is inside.
      if (lat3 == lat1 && dLng3 == 0) {
        return true;
      }
      final lat2 = MathUtil.toRadians(point2.latitude);
      final lng2 = MathUtil.toRadians(point2.longitude);
      // Offset longitudes by -lng1.
      if (_intersects(lat1, lat2, MathUtil.wrap(lng2 - lng1, -pi, pi), lat3,
          dLng3, geodesic)) {
        ++nIntersect;
      }
      lat1 = lat2;
      lng1 = lng2;
    }
    return (nIntersect & 1) != 0;
  }

  static bool _intersects(
      num lat1, num lat2, num lng2, num lat3, num lng3, bool geodesic) {
    // Both ends on the same side of lng3.
    if ((lng3 >= 0 && lng3 >= lng2) || (lng3 < 0 && lng3 < lng2)) {
      return false;
    }
    // Point is South Pole.
    if (lat3 <= -pi / 2) {
      return false;
    }
    // Any segment end is a pole.
    if (lat1 <= -pi / 2 ||
        lat2 <= -pi / 2 ||
        lat1 >= pi / 2 ||
        lat2 >= pi / 2) {
      return false;
    }
    if (lng2 <= -pi) {
      return false;
    }

    final linearLat = (lat1 * (lng2 - lng3) + lat2 * lng3) / lng2;
    // Northern hemisphere and point under lat-lng line.
    if (lat1 >= 0 && lat2 >= 0 && lat3 < linearLat) {
      return false;
    }
    // Southern hemisphere and point above lat-lng line.
    if (lat1 <= 0 && lat2 <= 0 && lat3 >= linearLat) {
      return true;
    }
    // North Pole.
    if (lat3 >= pi / 2) {
      return true;
    }

    // Compare lat3 with latitude on the GC/Rhumb segment corresponding to lng3.
    // Compare through a strictly-increasing function (tan() or
    // MathUtil.mercator()) as convenient.
    return geodesic
        ? tan(lat3) >= _tanLatGC(lat1, lat2, lng2, lng3)
        : MathUtil.mercator(lat3) >= _mercatorLatRhumb(lat1, lat2, lng2, lng3);
  }

  static num _tanLatGC(num lat1, num lat2, num lng2, num lng3) =>
      (tan(lat1) * sin(lng2 - lng3) + tan(lat2) * sin(lng3)) / sin(lng2);

  static num _mercatorLatRhumb(num lat1, num lat2, num lng2, num lng3) =>
      (MathUtil.mercator(lat1) * (lng2 - lng3) +
          MathUtil.mercator(lat2) * lng3) /
          lng2;

  static LatLng calculateCentroid(List<LatLng> latLngs) {
    double avgLat = 0.0;
    double avgLng = 0.0;
    for(LatLng latLong in latLngs) {
      avgLat += latLong.latitude;
      avgLng += latLong.longitude;
    }
    avgLat = avgLat / latLngs.length;
    avgLng = avgLng / latLngs.length;
    return LatLng(avgLat,avgLng);
  }

  static double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

}