/**
 * @fileoverview gRPC-Web generated client stub for MacDB
 * @enhanceable
 * @public
 */

// GENERATED CODE -- DO NOT EDIT!



const grpc = {};
grpc.web = require('grpc-web');

const proto = {};
proto.MacDB = require('./macdb_pb.js');

/**
 * @param {string} hostname
 * @param {?Object} credentials
 * @param {?Object} options
 * @constructor
 * @struct
 * @final
 */
proto.MacDB.WindowClient =
    function(hostname, credentials, options) {
  if (!options) options = {};
  options['format'] = 'text';

  /**
   * @private @const {!grpc.web.GrpcWebClientBase} The client
   */
  this.client_ = new grpc.web.GrpcWebClientBase(options);

  /**
   * @private @const {string} The hostname
   */
  this.hostname_ = hostname;

};


/**
 * @param {string} hostname
 * @param {?Object} credentials
 * @param {?Object} options
 * @constructor
 * @struct
 * @final
 */
proto.MacDB.WindowPromiseClient =
    function(hostname, credentials, options) {
  if (!options) options = {};
  options['format'] = 'text';

  /**
   * @private @const {!grpc.web.GrpcWebClientBase} The client
   */
  this.client_ = new grpc.web.GrpcWebClientBase(options);

  /**
   * @private @const {string} The hostname
   */
  this.hostname_ = hostname;

};


/**
 * @const
 * @type {!grpc.web.MethodDescriptor<
 *   !proto.MacDB.WindowInfo,
 *   !proto.MacDB.WindowCapture>}
 */
const methodDescriptor_Window_Capture = new grpc.web.MethodDescriptor(
  '/MacDB.Window/Capture',
  grpc.web.MethodType.SERVER_STREAMING,
  proto.MacDB.WindowInfo,
  proto.MacDB.WindowCapture,
  /**
   * @param {!proto.MacDB.WindowInfo} request
   * @return {!Uint8Array}
   */
  function(request) {
    return request.serializeBinary();
  },
  proto.MacDB.WindowCapture.deserializeBinary
);


/**
 * @const
 * @type {!grpc.web.AbstractClientBase.MethodInfo<
 *   !proto.MacDB.WindowInfo,
 *   !proto.MacDB.WindowCapture>}
 */
const methodInfo_Window_Capture = new grpc.web.AbstractClientBase.MethodInfo(
  proto.MacDB.WindowCapture,
  /**
   * @param {!proto.MacDB.WindowInfo} request
   * @return {!Uint8Array}
   */
  function(request) {
    return request.serializeBinary();
  },
  proto.MacDB.WindowCapture.deserializeBinary
);


/**
 * @param {!proto.MacDB.WindowInfo} request The request proto
 * @param {?Object<string, string>} metadata User defined
 *     call metadata
 * @return {!grpc.web.ClientReadableStream<!proto.MacDB.WindowCapture>}
 *     The XHR Node Readable Stream
 */
proto.MacDB.WindowClient.prototype.capture =
    function(request, metadata) {
  return this.client_.serverStreaming(this.hostname_ +
      '/MacDB.Window/Capture',
      request,
      metadata || {},
      methodDescriptor_Window_Capture);
};


/**
 * @param {!proto.MacDB.WindowInfo} request The request proto
 * @param {?Object<string, string>} metadata User defined
 *     call metadata
 * @return {!grpc.web.ClientReadableStream<!proto.MacDB.WindowCapture>}
 *     The XHR Node Readable Stream
 */
proto.MacDB.WindowPromiseClient.prototype.capture =
    function(request, metadata) {
  return this.client_.serverStreaming(this.hostname_ +
      '/MacDB.Window/Capture',
      request,
      metadata || {},
      methodDescriptor_Window_Capture);
};


/**
 * @const
 * @type {!grpc.web.MethodDescriptor<
 *   !proto.MacDB.WindowPoint,
 *   !proto.MacDB.WindowTouch>}
 */
const methodDescriptor_Window_Touch = new grpc.web.MethodDescriptor(
  '/MacDB.Window/Touch',
  grpc.web.MethodType.UNARY,
  proto.MacDB.WindowPoint,
  proto.MacDB.WindowTouch,
  /**
   * @param {!proto.MacDB.WindowPoint} request
   * @return {!Uint8Array}
   */
  function(request) {
    return request.serializeBinary();
  },
  proto.MacDB.WindowTouch.deserializeBinary
);


/**
 * @const
 * @type {!grpc.web.AbstractClientBase.MethodInfo<
 *   !proto.MacDB.WindowPoint,
 *   !proto.MacDB.WindowTouch>}
 */
const methodInfo_Window_Touch = new grpc.web.AbstractClientBase.MethodInfo(
  proto.MacDB.WindowTouch,
  /**
   * @param {!proto.MacDB.WindowPoint} request
   * @return {!Uint8Array}
   */
  function(request) {
    return request.serializeBinary();
  },
  proto.MacDB.WindowTouch.deserializeBinary
);


/**
 * @param {!proto.MacDB.WindowPoint} request The
 *     request proto
 * @param {?Object<string, string>} metadata User defined
 *     call metadata
 * @param {function(?grpc.web.Error, ?proto.MacDB.WindowTouch)}
 *     callback The callback function(error, response)
 * @return {!grpc.web.ClientReadableStream<!proto.MacDB.WindowTouch>|undefined}
 *     The XHR Node Readable Stream
 */
proto.MacDB.WindowClient.prototype.touch =
    function(request, metadata, callback) {
  return this.client_.rpcCall(this.hostname_ +
      '/MacDB.Window/Touch',
      request,
      metadata || {},
      methodDescriptor_Window_Touch,
      callback);
};


/**
 * @param {!proto.MacDB.WindowPoint} request The
 *     request proto
 * @param {?Object<string, string>} metadata User defined
 *     call metadata
 * @return {!Promise<!proto.MacDB.WindowTouch>}
 *     A native promise that resolves to the response
 */
proto.MacDB.WindowPromiseClient.prototype.touch =
    function(request, metadata) {
  return this.client_.unaryCall(this.hostname_ +
      '/MacDB.Window/Touch',
      request,
      metadata || {},
      methodDescriptor_Window_Touch);
};


module.exports = proto.MacDB;

