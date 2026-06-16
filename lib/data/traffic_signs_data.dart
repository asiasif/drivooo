class TrafficSignModel {
  final String name;
  final String imageUrl;
  final String description;

  TrafficSignModel({
    required this.name,
    required this.imageUrl,
    required this.description,
  });
}

List<TrafficSignModel> trafficSigns = [
  TrafficSignModel(
    name: "Stop",
    imageUrl: "assets/traffic_signs/stop.png",
    description: "Driver must stop completely.",
  ),
  TrafficSignModel(
    name: "Give Way",
    imageUrl: "assets/traffic_signs/give_way.png",
    description: "Yield to other traffic.",
  ),
  TrafficSignModel(
    name: "No Entry",
    imageUrl: "assets/traffic_signs/no_entry.png",
    description: "Entry is prohibited for all vehicles.",
  ),
  TrafficSignModel(
    name: "One Way",
    imageUrl: "assets/traffic_signs/one_way.png",
    description: "Traffic flow in one direction only.",
  ),
  TrafficSignModel(
    name: "No Parking",
    imageUrl: "assets/traffic_signs/no_parking.png",
    description: "Parking is not allowed.",
  ),
  TrafficSignModel(
    name: "No Stopping",
    imageUrl: "assets/traffic_signs/no_stopping.png",
    description: "Stopping is prohibited.",
  ),
  TrafficSignModel(
    name: "Speed Limit 50",
    imageUrl: "assets/traffic_signs/speed_limit_50.png",
    description: "Maximum speed limit is 50 km/h.",
  ),
  TrafficSignModel(
    name: "School Ahead",
    imageUrl: "assets/traffic_signs/school_ahead.png",
    description: "School zone, drive carefully.",
  ),
  TrafficSignModel(
    name: "Men at Work",
    imageUrl: "assets/traffic_signs/men_at_work.png",
    description: "Road work ahead.",
  ),
  TrafficSignModel(
    name: "Pedestrian Crossing",
    imageUrl: "assets/traffic_signs/pedestrian_crossing.png",
    description: "Watch out for pedestrians.",
  ),
  TrafficSignModel(
    name: "Right Turn Prohibited",
    imageUrl: "assets/traffic_signs/right_turn_prohibited.png",
    description: "Do not turn right.",
  ),
  TrafficSignModel(
    name: "Left Turn Prohibited",
    imageUrl: "assets/traffic_signs/left_turn_prohibited.png",
    description: "Do not turn left.",
  ),
  TrafficSignModel(
    name: "U-Turn Prohibited",
    imageUrl: "assets/traffic_signs/u_turn_prohibited.png",
    description: "U-Turn is not allowed.",
  ),
  TrafficSignModel(
    name: "Hump / Rough Road",
    imageUrl: "assets/traffic_signs/hump.png",
    description: "Speed breaker or rough road ahead.",
  ),
  TrafficSignModel(
    name: "Narrow Bridge",
    imageUrl: "assets/traffic_signs/narrow_bridge.png",
    description: "Bridge ahead is narrow.",
  ),
];
