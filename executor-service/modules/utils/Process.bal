import ballerina/jballerina.java;

# Ballerina class mapping for the Java `java.lang.Process` class.
@java:Binding {'class: "java.lang.Process"}
public distinct class Process {

    *java:JObject;
    *Object;

    # The `handle` field that stores the reference to the `java.lang.Process` object.
    public handle jObj;

    # The init function of the Ballerina class mapping the `java.lang.Process` Java class.
    #
    # + obj - The `handle` value containing the Java reference of the object.
    public function init(handle obj) {
        self.jObj = obj;
    }

    # The function to retrieve the string representation of the Ballerina class mapping the `java.lang.Process` Java class.
    #
    # + return - The `string` form of the Java object instance.
    public function toString() returns string {
        return java:toString(self.jObj) ?: "null";
    }
    # The function that maps to the `children` method of `java.lang.Process`.
    #
    # + return - The `Stream` value returning from the Java mapping.
    public function children() returns Stream {
        handle externalObj = java_lang_Process_children(self.jObj);
        Stream newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `descendants` method of `java.lang.Process`.
    #
    # + return - The `Stream` value returning from the Java mapping.
    public function descendants() returns Stream {
        handle externalObj = java_lang_Process_descendants(self.jObj);
        Stream newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `destroy` method of `java.lang.Process`.
    public function destroy() {
        java_lang_Process_destroy(self.jObj);
    }

    # The function that maps to the `destroyForcibly` method of `java.lang.Process`.
    #
    # + return - The `Process` value returning from the Java mapping.
    public function destroyForcibly() returns Process {
        handle externalObj = java_lang_Process_destroyForcibly(self.jObj);
        Process newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `equals` method of `java.lang.Process`.
    #
    # + arg0 - The `Object` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function 'equals(Object arg0) returns boolean {
        return java_lang_Process_equals(self.jObj, arg0.jObj);
    }

    # The function that maps to the `exitValue` method of `java.lang.Process`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function exitValue() returns int {
        return java_lang_Process_exitValue(self.jObj);
    }

    # The function that maps to the `getClass` method of `java.lang.Process`.
    #
    # + return - The `Class` value returning from the Java mapping.
    public function getClass() returns Class {
        handle externalObj = java_lang_Process_getClass(self.jObj);
        Class newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `getErrorStream` method of `java.lang.Process`.
    #
    # + return - The `InputStream` value returning from the Java mapping.
    public function getErrorStream() returns InputStream {
        handle externalObj = java_lang_Process_getErrorStream(self.jObj);
        InputStream newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `getInputStream` method of `java.lang.Process`.
    #
    # + return - The `InputStream` value returning from the Java mapping.
    public function getInputStream() returns InputStream {
        handle externalObj = java_lang_Process_getInputStream(self.jObj);
        InputStream newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `getOutputStream` method of `java.lang.Process`.
    #
    # + return - The `OutputStream` value returning from the Java mapping.
    public function getOutputStream() returns OutputStream {
        handle externalObj = java_lang_Process_getOutputStream(self.jObj);
        OutputStream newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `hashCode` method of `java.lang.Process`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function hashCode() returns int {
        return java_lang_Process_hashCode(self.jObj);
    }

    # The function that maps to the `info` method of `java.lang.Process`.
    #
    # + return - The `Info` value returning from the Java mapping.
    public function info() returns Info {
        handle externalObj = java_lang_Process_info(self.jObj);
        Info newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `isAlive` method of `java.lang.Process`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function isAlive() returns boolean {
        return java_lang_Process_isAlive(self.jObj);
    }

    # The function that maps to the `notify` method of `java.lang.Process`.
    public function notify() {
        java_lang_Process_notify(self.jObj);
    }

    # The function that maps to the `notifyAll` method of `java.lang.Process`.
    public function notifyAll() {
        java_lang_Process_notifyAll(self.jObj);
    }

    # The function that maps to the `onExit` method of `java.lang.Process`.
    #
    # + return - The `CompletableFuture` value returning from the Java mapping.
    public function onExit() returns CompletableFuture {
        handle externalObj = java_lang_Process_onExit(self.jObj);
        CompletableFuture newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `pid` method of `java.lang.Process`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function pid() returns int {
        return java_lang_Process_pid(self.jObj);
    }

    # The function that maps to the `supportsNormalTermination` method of `java.lang.Process`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function supportsNormalTermination() returns boolean {
        return java_lang_Process_supportsNormalTermination(self.jObj);
    }

    # The function that maps to the `toHandle` method of `java.lang.Process`.
    #
    # + return - The `ProcessHandle` value returning from the Java mapping.
    public function toHandle() returns ProcessHandle {
        handle externalObj = java_lang_Process_toHandle(self.jObj);
        ProcessHandle newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `wait` method of `java.lang.Process`.
    #
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function 'wait() returns InterruptedException? {
        error|() externalObj = java_lang_Process_wait(self.jObj);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `java.lang.Process`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function wait2(int arg0) returns InterruptedException? {
        error|() externalObj = java_lang_Process_wait2(self.jObj, arg0);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `java.lang.Process`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + arg1 - The `int` value required to map with the Java method parameter.
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function wait3(int arg0, int arg1) returns InterruptedException? {
        error|() externalObj = java_lang_Process_wait3(self.jObj, arg0, arg1);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `waitFor` method of `java.lang.Process`.
    #
    # + return - The `int` or the `InterruptedException` value returning from the Java mapping.
    public function waitFor() returns int|InterruptedException {
        int|error externalObj = java_lang_Process_waitFor(self.jObj);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `waitFor` method of `java.lang.Process`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + arg1 - The `TimeUnit` value required to map with the Java method parameter.
    # + return - The `boolean` or the `InterruptedException` value returning from the Java mapping.
    public function waitFor2(int arg0, TimeUnit arg1) returns boolean|InterruptedException {
        boolean|error externalObj = java_lang_Process_waitFor2(self.jObj, arg0, arg1.jObj);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

}

# The constructor function to generate an object of `java.lang.Process`.
#
# + return - The new `Process` class generated.
public function newProcess1() returns Process {
    handle externalObj = java_lang_Process_newProcess1();
    Process newObj = new (externalObj);
    return newObj;
}

function java_lang_Process_children(handle receiver) returns handle = @java:Method {
    name: "children",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_descendants(handle receiver) returns handle = @java:Method {
    name: "descendants",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_destroy(handle receiver) = @java:Method {
    name: "destroy",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_destroyForcibly(handle receiver) returns handle = @java:Method {
    name: "destroyForcibly",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_equals(handle receiver, handle arg0) returns boolean = @java:Method {
    name: "equals",
    'class: "java.lang.Process",
    paramTypes: ["java.lang.Object"]
} external;

function java_lang_Process_exitValue(handle receiver) returns int = @java:Method {
    name: "exitValue",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_getClass(handle receiver) returns handle = @java:Method {
    name: "getClass",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_getErrorStream(handle receiver) returns handle = @java:Method {
    name: "getErrorStream",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_getInputStream(handle receiver) returns handle = @java:Method {
    name: "getInputStream",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_getOutputStream(handle receiver) returns handle = @java:Method {
    name: "getOutputStream",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_hashCode(handle receiver) returns int = @java:Method {
    name: "hashCode",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_info(handle receiver) returns handle = @java:Method {
    name: "info",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_isAlive(handle receiver) returns boolean = @java:Method {
    name: "isAlive",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_notify(handle receiver) = @java:Method {
    name: "notify",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_notifyAll(handle receiver) = @java:Method {
    name: "notifyAll",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_onExit(handle receiver) returns handle = @java:Method {
    name: "onExit",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_pid(handle receiver) returns int = @java:Method {
    name: "pid",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_supportsNormalTermination(handle receiver) returns boolean = @java:Method {
    name: "supportsNormalTermination",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_toHandle(handle receiver) returns handle = @java:Method {
    name: "toHandle",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_wait(handle receiver) returns error? = @java:Method {
    name: "wait",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_wait2(handle receiver, int arg0) returns error? = @java:Method {
    name: "wait",
    'class: "java.lang.Process",
    paramTypes: ["long"]
} external;

function java_lang_Process_wait3(handle receiver, int arg0, int arg1) returns error? = @java:Method {
    name: "wait",
    'class: "java.lang.Process",
    paramTypes: ["long", "int"]
} external;

function java_lang_Process_waitFor(handle receiver) returns int|error = @java:Method {
    name: "waitFor",
    'class: "java.lang.Process",
    paramTypes: []
} external;

function java_lang_Process_waitFor2(handle receiver, int arg0, handle arg1) returns boolean|error = @java:Method {
    name: "waitFor",
    'class: "java.lang.Process",
    paramTypes: ["long", "java.util.concurrent.TimeUnit"]
} external;

function java_lang_Process_newProcess1() returns handle = @java:Constructor {
    'class: "java.lang.Process",
    paramTypes: []
} external;

