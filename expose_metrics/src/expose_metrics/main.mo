import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Prim "mo:prim";
import StableMemory "mo:base/ExperimentalStableMemory";
import Text "mo:base/Text";

actor ExposeMetrics {

  type HeaderField = (Text, Text);

  type HttpResponse = {
    status_code: Nat16;
    headers: [HeaderField];
    body: Blob;
  };
  
  type HttpRequest = {
    method: Text;
    url: Text;
    headers: [HeaderField];
    body: Blob;
  };
  
  public query func http_request(req : HttpRequest) : async HttpResponse {
    // Strip query params and get only path
    let ?path = Text.split(req.url, #char '?').next();
    Debug.print(req.url);
    Debug.print(path);
    switch (req.method, path) {
      // Endpoint that serves metrics to be consumed with Prometheseus
      case ("GET", "/metrics") {
        Debug.print("GET: /metrics");
        let m = metrics();
        Debug.print(m);
        {
          status_code =  200;
          headers = [ ("content-type", "text/plain") ];
          body =  Text.encodeUtf8(m);
        }
      };
      case _ {
        Debug.print("Invalid request");
        {
          status_code = 400;
          headers = [];
          body = "Invalid request";
        }
      };
    } 
  };

  // Returns a set of metrics encoded in Prometheseus text-based exposition format
  // https://github.com/prometheus/docs/blob/main/content/docs/instrumenting/exposition_formats.md
  // More info on the specific metrics can be found in the following forum threads:
  // https://forum.dfinity.org/t/motoko-get-canisters-sizes-limits/2092
  // https://forum.dfinity.org/t/motoko-array-memory/5324/4
  func metrics() : Text {

    "balance{} " # Nat.toText(Cycles.balance()) # "\n" #
    "heap_size{} " # Nat.toText(Prim.rts_heap_size()) # "\n" #
    "mem_size{} " # Nat.toText(Prim.rts_memory_size()) # "\n" #
    "stable_mem_size{} " # Nat64.toText(StableMemory.size());

  };

};
