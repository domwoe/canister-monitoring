import Cycles "mo:base/ExperimentalCycles";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
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
    switch (req.method, req.url) {
      // Endpoint that serves metrics to be consumed with Prometheseus
      case ("GET", "/metrics") {{
        status_code =  200;
        headers = [ ("content-type", "text/plain") ];
        body = metrics();
      }};
      case _ {{
        status_code = 400;
        headers = [];
        body = "Invalid request";
      }};
    } 
  };

  // Returns a set of metrics encoded in Prometheseus text-based exposition format
  // https://github.com/prometheus/docs/blob/main/content/docs/instrumenting/exposition_formats.md
  // More info on the specific metrics can be found in the following forum threads:
  // https://forum.dfinity.org/t/motoko-get-canisters-sizes-limits/2092
  // https://forum.dfinity.org/t/motoko-array-memory/5324/4
  func metrics() : Blob {

    let balance = "balance=" # Nat.toText(Cycles.balance());
    let heap_size = "heap_size=" # Nat.toText(Prim.rts_heap_size());
    let mem_size = "mem_size=" # Nat.toText(Prim.rts_memory_size());
    let stable_mem_size = "stable_mem_size=" # Nat64.toText(StableMemory.size());

    let metrics = "metrics{" # balance # "," # heap_size # "," # mem_size # "," # stable_mem_size # "}";
    Text.encodeUtf8(metrics);
  };

};
