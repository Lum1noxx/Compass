
import 'package:clientapp/data.dart';
import 'package:clientapp/main.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Globals.destinations = Destinations(
    [
      "com3",
      'com4',
      'WS Lab 1'
    ]
    , 2
    );
  Globals.nodes = Nodes();
  test("getDest", () async{
    DirectionsModel model = DirectionsModel();
    Destination dest = await model.getDest("com4");
    expect(dest.name, "com4");
  });
  test("queryAutocomplete", () {
    DirectionsModel model =  DirectionsModel();
    List<String> res = model.queryAutocomplete("m3");
    expect(res, ["com3", "com4"]);
  });
  group("findPath and getNodesOnPath", () {

    test("first findPath", () async{
      DirectionsModel model =  DirectionsModel();
      Destination com3 = await Globals.destinations.get("com3");
      Destination com4 = await Globals.destinations.get("com4");
      List<Edge> edges = await model.findPath(com3, com4);
      Node prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
      expect(model.getNodeOnPath(edges.first.end.name), edges.first.end);
    });
    test("second findPath", () async{
      DirectionsModel model =  DirectionsModel();
      Destination com3 = await Globals.destinations.get("com3");
      Destination com4 = await Globals.destinations.get("com4");
      await model.findPath(com3, com4);
      Destination wslab = await Globals.destinations.get("WS Lab 1");
      List<Edge> edges = await model.findPath(com4, wslab);
      Node prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
      expect(model.getNodeOnPath(edges.first.end.name), edges.first.end);
    });

  });
}