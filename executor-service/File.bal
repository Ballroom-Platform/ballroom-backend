import ballerina/jballerina.java;
import ballerina/jballerina.java.arrays as jarrays;

# Ballerina class mapping for the Java `java.io.File` class.
@java:Binding {'class: "java.io.File"}
public distinct class File {

    *java:JObject;
    *Object;

    # The `handle` field that stores the reference to the `java.io.File` object.
    public handle jObj;

    # The init function of the Ballerina class mapping the `java.io.File` Java class.
    #
    # + obj - The `handle` value containing the Java reference of the object.
    public function init(handle obj) {
        self.jObj = obj;
    }

    # The function to retrieve the string representation of the Ballerina class mapping the `java.io.File` Java class.
    #
    # + return - The `string` form of the Java object instance.
    public function toString() returns string {
        return java:toString(self.jObj) ?: "null";
    }
    # The function that maps to the `canExecute` method of `java.io.File`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function canExecute() returns boolean {
        return java_io_File_canExecute(self.jObj);
    }

    # The function that maps to the `canRead` method of `java.io.File`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function canRead() returns boolean {
        return java_io_File_canRead(self.jObj);
    }

    # The function that maps to the `canWrite` method of `java.io.File`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function canWrite() returns boolean {
        return java_io_File_canWrite(self.jObj);
    }

    # The function that maps to the `compareTo` method of `java.io.File`.
    #
    # + arg0 - The `File` value required to map with the Java method parameter.
    # + return - The `int` value returning from the Java mapping.
    public function compareTo(File arg0) returns int {
        return java_io_File_compareTo(self.jObj, arg0.jObj);
    }

    # The function that maps to the `createNewFile` method of `java.io.File`.
    #
    # + return - The `boolean` or the `IOException` value returning from the Java mapping.
    public function createNewFile() returns boolean|IOException {
        boolean|error externalObj = java_io_File_createNewFile(self.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `delete` method of `java.io.File`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function delete() returns boolean {
        return java_io_File_delete(self.jObj);
    }

    # The function that maps to the `deleteOnExit` method of `java.io.File`.
    public function deleteOnExit() {
        java_io_File_deleteOnExit(self.jObj);
    }

    # The function that maps to the `equals` method of `java.io.File`.
    #
    # + arg0 - The `Object` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function 'equals(Object arg0) returns boolean {
        return java_io_File_equals(self.jObj, arg0.jObj);
    }

    # The function that maps to the `exists` method of `java.io.File`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function exists() returns boolean {
        return java_io_File_exists(self.jObj);
    }

    # The function that maps to the `getAbsoluteFile` method of `java.io.File`.
    #
    # + return - The `File` value returning from the Java mapping.
    public function getAbsoluteFile() returns File {
        handle externalObj = java_io_File_getAbsoluteFile(self.jObj);
        File newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `getAbsolutePath` method of `java.io.File`.
    #
    # + return - The `string` value returning from the Java mapping.
    public function getAbsolutePath() returns string? {
        return java:toString(java_io_File_getAbsolutePath(self.jObj));
    }

    # The function that maps to the `getCanonicalFile` method of `java.io.File`.
    #
    # + return - The `File` or the `IOException` value returning from the Java mapping.
    public function getCanonicalFile() returns File|IOException {
        handle|error externalObj = java_io_File_getCanonicalFile(self.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            File newObj = new (externalObj);
            return newObj;
        }
    }

    # The function that maps to the `getCanonicalPath` method of `java.io.File`.
    #
    # + return - The `string` or the `IOException` value returning from the Java mapping.
    public function getCanonicalPath() returns string?|IOException {
        handle|error externalObj = java_io_File_getCanonicalPath(self.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return java:toString(externalObj);
        }
    }

    # The function that maps to the `getClass` method of `java.io.File`.
    #
    # + return - The `Class` value returning from the Java mapping.
    public function getClass() returns Class {
        handle externalObj = java_io_File_getClass(self.jObj);
        Class newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `getFreeSpace` method of `java.io.File`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function getFreeSpace() returns int {
        return java_io_File_getFreeSpace(self.jObj);
    }

    # The function that maps to the `getName` method of `java.io.File`.
    #
    # + return - The `string` value returning from the Java mapping.
    public function getName() returns string? {
        return java:toString(java_io_File_getName(self.jObj));
    }

    # The function that maps to the `getParent` method of `java.io.File`.
    #
    # + return - The `string` value returning from the Java mapping.
    public function getParent() returns string? {
        return java:toString(java_io_File_getParent(self.jObj));
    }

    # The function that maps to the `getParentFile` method of `java.io.File`.
    #
    # + return - The `File` value returning from the Java mapping.
    public function getParentFile() returns File {
        handle externalObj = java_io_File_getParentFile(self.jObj);
        File newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `getPath` method of `java.io.File`.
    #
    # + return - The `string` value returning from the Java mapping.
    public function getPath() returns string? {
        return java:toString(java_io_File_getPath(self.jObj));
    }

    # The function that maps to the `getTotalSpace` method of `java.io.File`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function getTotalSpace() returns int {
        return java_io_File_getTotalSpace(self.jObj);
    }

    # The function that maps to the `getUsableSpace` method of `java.io.File`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function getUsableSpace() returns int {
        return java_io_File_getUsableSpace(self.jObj);
    }

    # The function that maps to the `hashCode` method of `java.io.File`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function hashCode() returns int {
        return java_io_File_hashCode(self.jObj);
    }

    # The function that maps to the `isAbsolute` method of `java.io.File`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function isAbsolute() returns boolean {
        return java_io_File_isAbsolute(self.jObj);
    }

    # The function that maps to the `isDirectory` method of `java.io.File`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function isDirectory() returns boolean {
        return java_io_File_isDirectory(self.jObj);
    }

    # The function that maps to the `isFile` method of `java.io.File`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function isFile() returns boolean {
        return java_io_File_isFile(self.jObj);
    }

    # The function that maps to the `isHidden` method of `java.io.File`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function isHidden() returns boolean {
        return java_io_File_isHidden(self.jObj);
    }

    # The function that maps to the `lastModified` method of `java.io.File`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function lastModified() returns int {
        return java_io_File_lastModified(self.jObj);
    }

    # The function that maps to the `length` method of `java.io.File`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function length() returns int {
        return java_io_File_length(self.jObj);
    }

    # The function that maps to the `list` method of `java.io.File`.
    #
    # + return - The `string[]` value returning from the Java mapping.
    public function list() returns string[]?|error {
        handle externalObj = java_io_File_list(self.jObj);
        if java:isNull(externalObj) {
            return null;
        }
        return <string[]>check jarrays:fromHandle(externalObj, "string");
    }

    # The function that maps to the `list` method of `java.io.File`.
    #
    # + arg0 - The `FilenameFilter` value required to map with the Java method parameter.
    # + return - The `string[]` value returning from the Java mapping.
    public function list2(FilenameFilter arg0) returns string[]?|error {
        handle externalObj = java_io_File_list2(self.jObj, arg0.jObj);
        if java:isNull(externalObj) {
            return null;
        }
        return <string[]>check jarrays:fromHandle(externalObj, "string");
    }

    # The function that maps to the `listFiles` method of `java.io.File`.
    #
    # + return - The `File[]` value returning from the Java mapping.
    public function listFiles() returns File[]|error {
        handle externalObj = java_io_File_listFiles(self.jObj);
        File[] newObj = [];
        handle[] anyObj = <handle[]>check jarrays:fromHandle(externalObj, "handle");
        int count = anyObj.length();
        foreach int i in 0 ... count - 1 {
            File element = new (anyObj[i]);
            newObj[i] = element;
        }
        return newObj;
    }

    # The function that maps to the `listFiles` method of `java.io.File`.
    #
    # + arg0 - The `FileFilter` value required to map with the Java method parameter.
    # + return - The `File[]` value returning from the Java mapping.
    public function listFiles2(FileFilter arg0) returns File[]|error {
        handle externalObj = java_io_File_listFiles2(self.jObj, arg0.jObj);
        File[] newObj = [];
        handle[] anyObj = <handle[]>check jarrays:fromHandle(externalObj, "handle");
        int count = anyObj.length();
        foreach int i in 0 ... count - 1 {
            File element = new (anyObj[i]);
            newObj[i] = element;
        }
        return newObj;
    }

    # The function that maps to the `listFiles` method of `java.io.File`.
    #
    # + arg0 - The `FilenameFilter` value required to map with the Java method parameter.
    # + return - The `File[]` value returning from the Java mapping.
    public function listFiles3(FilenameFilter arg0) returns File[]|error {
        handle externalObj = java_io_File_listFiles3(self.jObj, arg0.jObj);
        File[] newObj = [];
        handle[] anyObj = <handle[]>check jarrays:fromHandle(externalObj, "handle");
        int count = anyObj.length();
        foreach int i in 0 ... count - 1 {
            File element = new (anyObj[i]);
            newObj[i] = element;
        }
        return newObj;
    }

    # The function that maps to the `mkdir` method of `java.io.File`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function mkdir() returns boolean {
        return java_io_File_mkdir(self.jObj);
    }

    # The function that maps to the `mkdirs` method of `java.io.File`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function mkdirs() returns boolean {
        return java_io_File_mkdirs(self.jObj);
    }

    # The function that maps to the `notify` method of `java.io.File`.
    public function notify() {
        java_io_File_notify(self.jObj);
    }

    # The function that maps to the `notifyAll` method of `java.io.File`.
    public function notifyAll() {
        java_io_File_notifyAll(self.jObj);
    }

    # The function that maps to the `renameTo` method of `java.io.File`.
    #
    # + arg0 - The `File` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function renameTo(File arg0) returns boolean {
        return java_io_File_renameTo(self.jObj, arg0.jObj);
    }

    # The function that maps to the `setExecutable` method of `java.io.File`.
    #
    # + arg0 - The `boolean` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function setExecutable(boolean arg0) returns boolean {
        return java_io_File_setExecutable(self.jObj, arg0);
    }

    # The function that maps to the `setExecutable` method of `java.io.File`.
    #
    # + arg0 - The `boolean` value required to map with the Java method parameter.
    # + arg1 - The `boolean` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function setExecutable2(boolean arg0, boolean arg1) returns boolean {
        return java_io_File_setExecutable2(self.jObj, arg0, arg1);
    }

    # The function that maps to the `setLastModified` method of `java.io.File`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function setLastModified(int arg0) returns boolean {
        return java_io_File_setLastModified(self.jObj, arg0);
    }

    # The function that maps to the `setReadOnly` method of `java.io.File`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function setReadOnly() returns boolean {
        return java_io_File_setReadOnly(self.jObj);
    }

    # The function that maps to the `setReadable` method of `java.io.File`.
    #
    # + arg0 - The `boolean` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function setReadable(boolean arg0) returns boolean {
        return java_io_File_setReadable(self.jObj, arg0);
    }

    # The function that maps to the `setReadable` method of `java.io.File`.
    #
    # + arg0 - The `boolean` value required to map with the Java method parameter.
    # + arg1 - The `boolean` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function setReadable2(boolean arg0, boolean arg1) returns boolean {
        return java_io_File_setReadable2(self.jObj, arg0, arg1);
    }

    # The function that maps to the `setWritable` method of `java.io.File`.
    #
    # + arg0 - The `boolean` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function setWritable(boolean arg0) returns boolean {
        return java_io_File_setWritable(self.jObj, arg0);
    }

    # The function that maps to the `setWritable` method of `java.io.File`.
    #
    # + arg0 - The `boolean` value required to map with the Java method parameter.
    # + arg1 - The `boolean` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function setWritable2(boolean arg0, boolean arg1) returns boolean {
        return java_io_File_setWritable2(self.jObj, arg0, arg1);
    }

    # The function that maps to the `toPath` method of `java.io.File`.
    #
    # + return - The `Path` value returning from the Java mapping.
    public function toPath() returns Path {
        handle externalObj = java_io_File_toPath(self.jObj);
        Path newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `toURI` method of `java.io.File`.
    #
    # + return - The `URI` value returning from the Java mapping.
    public function toURI() returns URI {
        handle externalObj = java_io_File_toURI(self.jObj);
        URI newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `toURL` method of `java.io.File`.
    #
    # + return - The `URL` or the `MalformedURLException` value returning from the Java mapping.
    public function toURL() returns URL|MalformedURLException {
        handle|error externalObj = java_io_File_toURL(self.jObj);
        if (externalObj is error) {
            MalformedURLException e = error MalformedURLException(MALFORMEDURLEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            URL newObj = new (externalObj);
            return newObj;
        }
    }

    # The function that maps to the `wait` method of `java.io.File`.
    #
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function 'wait() returns InterruptedException? {
        error|() externalObj = java_io_File_wait(self.jObj);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `java.io.File`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function wait2(int arg0) returns InterruptedException? {
        error|() externalObj = java_io_File_wait2(self.jObj, arg0);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `java.io.File`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + arg1 - The `int` value required to map with the Java method parameter.
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function wait3(int arg0, int arg1) returns InterruptedException? {
        error|() externalObj = java_io_File_wait3(self.jObj, arg0, arg1);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

}

# The constructor function to generate an object of `java.io.File`.
#
# + arg0 - The `File` value required to map with the Java constructor parameter.
# + arg1 - The `string` value required to map with the Java constructor parameter.
# + return - The new `File` class generated.
public function newFile1(File arg0, string arg1) returns File {
    handle externalObj = java_io_File_newFile1(arg0.jObj, java:fromString(arg1));
    File newObj = new (externalObj);
    return newObj;
}

# The constructor function to generate an object of `java.io.File`.
#
# + arg0 - The `string` value required to map with the Java constructor parameter.
# + return - The new `File` class generated.
public function newFile2(string arg0) returns File {
    handle externalObj = java_io_File_newFile2(java:fromString(arg0));
    File newObj = new (externalObj);
    return newObj;
}

# The constructor function to generate an object of `java.io.File`.
#
# + arg0 - The `string` value required to map with the Java constructor parameter.
# + arg1 - The `string` value required to map with the Java constructor parameter.
# + return - The new `File` class generated.
public function newFile3(string arg0, string arg1) returns File {
    handle externalObj = java_io_File_newFile3(java:fromString(arg0), java:fromString(arg1));
    File newObj = new (externalObj);
    return newObj;
}

# The constructor function to generate an object of `java.io.File`.
#
# + arg0 - The `URI` value required to map with the Java constructor parameter.
# + return - The new `File` class generated.
public function newFile4(URI arg0) returns File {
    handle externalObj = java_io_File_newFile4(arg0.jObj);
    File newObj = new (externalObj);
    return newObj;
}

# The function that maps to the `createTempFile` method of `java.io.File`.
#
# + arg0 - The `string` value required to map with the Java method parameter.
# + arg1 - The `string` value required to map with the Java method parameter.
# + return - The `File` or the `IOException` value returning from the Java mapping.
public function File_createTempFile(string arg0, string arg1) returns File|IOException {
    handle|error externalObj = java_io_File_createTempFile(java:fromString(arg0), java:fromString(arg1));
    if (externalObj is error) {
        IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
        return e;
    } else {
        File newObj = new (externalObj);
        return newObj;
    }
}

# The function that maps to the `createTempFile` method of `java.io.File`.
#
# + arg0 - The `string` value required to map with the Java method parameter.
# + arg1 - The `string` value required to map with the Java method parameter.
# + arg2 - The `File` value required to map with the Java method parameter.
# + return - The `File` or the `IOException` value returning from the Java mapping.
public function File_createTempFile2(string arg0, string arg1, File arg2) returns File|IOException {
    handle|error externalObj = java_io_File_createTempFile2(java:fromString(arg0), java:fromString(arg1), arg2.jObj);
    if (externalObj is error) {
        IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
        return e;
    } else {
        File newObj = new (externalObj);
        return newObj;
    }
}

# The function that maps to the `listRoots` method of `java.io.File`.
#
# + return - The `File[]` value returning from the Java mapping.
public function File_listRoots() returns File[]|error {
    handle externalObj = java_io_File_listRoots();
    File[] newObj = [];
    handle[] anyObj = <handle[]>check jarrays:fromHandle(externalObj, "handle");
    int count = anyObj.length();
    foreach int i in 0 ... count - 1 {
        File element = new (anyObj[i]);
        newObj[i] = element;
    }
    return newObj;
}

# The function that retrieves the value of the public field `separatorChar`.
#
# + return - The `int` value of the field.
public function File_getSeparatorChar() returns int {
    return java_io_File_getSeparatorChar();
}

# The function that retrieves the value of the public field `separator`.
#
# + return - The `string` value of the field.
public function File_getSeparator() returns string? {
    return java:toString(java_io_File_getSeparator());
}

# The function that retrieves the value of the public field `pathSeparatorChar`.
#
# + return - The `int` value of the field.
public function File_getPathSeparatorChar() returns int {
    return java_io_File_getPathSeparatorChar();
}

# The function that retrieves the value of the public field `pathSeparator`.
#
# + return - The `string` value of the field.
public function File_getPathSeparator() returns string? {
    return java:toString(java_io_File_getPathSeparator());
}

function java_io_File_canExecute(handle receiver) returns boolean = @java:Method {
    name: "canExecute",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_canRead(handle receiver) returns boolean = @java:Method {
    name: "canRead",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_canWrite(handle receiver) returns boolean = @java:Method {
    name: "canWrite",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_compareTo(handle receiver, handle arg0) returns int = @java:Method {
    name: "compareTo",
    'class: "java.io.File",
    paramTypes: ["java.io.File"]
} external;

function java_io_File_createNewFile(handle receiver) returns boolean|error = @java:Method {
    name: "createNewFile",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_createTempFile(handle arg0, handle arg1) returns handle|error = @java:Method {
    name: "createTempFile",
    'class: "java.io.File",
    paramTypes: ["java.lang.String", "java.lang.String"]
} external;

function java_io_File_createTempFile2(handle arg0, handle arg1, handle arg2) returns handle|error = @java:Method {
    name: "createTempFile",
    'class: "java.io.File",
    paramTypes: ["java.lang.String", "java.lang.String", "java.io.File"]
} external;

function java_io_File_delete(handle receiver) returns boolean = @java:Method {
    name: "delete",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_deleteOnExit(handle receiver) = @java:Method {
    name: "deleteOnExit",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_equals(handle receiver, handle arg0) returns boolean = @java:Method {
    name: "equals",
    'class: "java.io.File",
    paramTypes: ["java.lang.Object"]
} external;

function java_io_File_exists(handle receiver) returns boolean = @java:Method {
    name: "exists",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_getAbsoluteFile(handle receiver) returns handle = @java:Method {
    name: "getAbsoluteFile",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_getAbsolutePath(handle receiver) returns handle = @java:Method {
    name: "getAbsolutePath",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_getCanonicalFile(handle receiver) returns handle|error = @java:Method {
    name: "getCanonicalFile",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_getCanonicalPath(handle receiver) returns handle|error = @java:Method {
    name: "getCanonicalPath",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_getClass(handle receiver) returns handle = @java:Method {
    name: "getClass",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_getFreeSpace(handle receiver) returns int = @java:Method {
    name: "getFreeSpace",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_getName(handle receiver) returns handle = @java:Method {
    name: "getName",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_getParent(handle receiver) returns handle = @java:Method {
    name: "getParent",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_getParentFile(handle receiver) returns handle = @java:Method {
    name: "getParentFile",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_getPath(handle receiver) returns handle = @java:Method {
    name: "getPath",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_getTotalSpace(handle receiver) returns int = @java:Method {
    name: "getTotalSpace",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_getUsableSpace(handle receiver) returns int = @java:Method {
    name: "getUsableSpace",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_hashCode(handle receiver) returns int = @java:Method {
    name: "hashCode",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_isAbsolute(handle receiver) returns boolean = @java:Method {
    name: "isAbsolute",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_isDirectory(handle receiver) returns boolean = @java:Method {
    name: "isDirectory",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_isFile(handle receiver) returns boolean = @java:Method {
    name: "isFile",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_isHidden(handle receiver) returns boolean = @java:Method {
    name: "isHidden",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_lastModified(handle receiver) returns int = @java:Method {
    name: "lastModified",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_length(handle receiver) returns int = @java:Method {
    name: "length",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_list(handle receiver) returns handle = @java:Method {
    name: "list",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_list2(handle receiver, handle arg0) returns handle = @java:Method {
    name: "list",
    'class: "java.io.File",
    paramTypes: ["java.io.FilenameFilter"]
} external;

function java_io_File_listFiles(handle receiver) returns handle = @java:Method {
    name: "listFiles",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_listFiles2(handle receiver, handle arg0) returns handle = @java:Method {
    name: "listFiles",
    'class: "java.io.File",
    paramTypes: ["java.io.FileFilter"]
} external;

function java_io_File_listFiles3(handle receiver, handle arg0) returns handle = @java:Method {
    name: "listFiles",
    'class: "java.io.File",
    paramTypes: ["java.io.FilenameFilter"]
} external;

function java_io_File_listRoots() returns handle = @java:Method {
    name: "listRoots",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_mkdir(handle receiver) returns boolean = @java:Method {
    name: "mkdir",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_mkdirs(handle receiver) returns boolean = @java:Method {
    name: "mkdirs",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_notify(handle receiver) = @java:Method {
    name: "notify",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_notifyAll(handle receiver) = @java:Method {
    name: "notifyAll",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_renameTo(handle receiver, handle arg0) returns boolean = @java:Method {
    name: "renameTo",
    'class: "java.io.File",
    paramTypes: ["java.io.File"]
} external;

function java_io_File_setExecutable(handle receiver, boolean arg0) returns boolean = @java:Method {
    name: "setExecutable",
    'class: "java.io.File",
    paramTypes: ["boolean"]
} external;

function java_io_File_setExecutable2(handle receiver, boolean arg0, boolean arg1) returns boolean = @java:Method {
    name: "setExecutable",
    'class: "java.io.File",
    paramTypes: ["boolean", "boolean"]
} external;

function java_io_File_setLastModified(handle receiver, int arg0) returns boolean = @java:Method {
    name: "setLastModified",
    'class: "java.io.File",
    paramTypes: ["long"]
} external;

function java_io_File_setReadOnly(handle receiver) returns boolean = @java:Method {
    name: "setReadOnly",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_setReadable(handle receiver, boolean arg0) returns boolean = @java:Method {
    name: "setReadable",
    'class: "java.io.File",
    paramTypes: ["boolean"]
} external;

function java_io_File_setReadable2(handle receiver, boolean arg0, boolean arg1) returns boolean = @java:Method {
    name: "setReadable",
    'class: "java.io.File",
    paramTypes: ["boolean", "boolean"]
} external;

function java_io_File_setWritable(handle receiver, boolean arg0) returns boolean = @java:Method {
    name: "setWritable",
    'class: "java.io.File",
    paramTypes: ["boolean"]
} external;

function java_io_File_setWritable2(handle receiver, boolean arg0, boolean arg1) returns boolean = @java:Method {
    name: "setWritable",
    'class: "java.io.File",
    paramTypes: ["boolean", "boolean"]
} external;

function java_io_File_toPath(handle receiver) returns handle = @java:Method {
    name: "toPath",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_toURI(handle receiver) returns handle = @java:Method {
    name: "toURI",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_toURL(handle receiver) returns handle|error = @java:Method {
    name: "toURL",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_wait(handle receiver) returns error? = @java:Method {
    name: "wait",
    'class: "java.io.File",
    paramTypes: []
} external;

function java_io_File_wait2(handle receiver, int arg0) returns error? = @java:Method {
    name: "wait",
    'class: "java.io.File",
    paramTypes: ["long"]
} external;

function java_io_File_wait3(handle receiver, int arg0, int arg1) returns error? = @java:Method {
    name: "wait",
    'class: "java.io.File",
    paramTypes: ["long", "int"]
} external;

function java_io_File_getSeparatorChar() returns int = @java:FieldGet {
    name: "separatorChar",
    'class: "java.io.File"
} external;

function java_io_File_getSeparator() returns handle = @java:FieldGet {
    name: "separator",
    'class: "java.io.File"
} external;

function java_io_File_getPathSeparatorChar() returns int = @java:FieldGet {
    name: "pathSeparatorChar",
    'class: "java.io.File"
} external;

function java_io_File_getPathSeparator() returns handle = @java:FieldGet {
    name: "pathSeparator",
    'class: "java.io.File"
} external;

function java_io_File_newFile1(handle arg0, handle arg1) returns handle = @java:Constructor {
    'class: "java.io.File",
    paramTypes: ["java.io.File", "java.lang.String"]
} external;

function java_io_File_newFile2(handle arg0) returns handle = @java:Constructor {
    'class: "java.io.File",
    paramTypes: ["java.lang.String"]
} external;

function java_io_File_newFile3(handle arg0, handle arg1) returns handle = @java:Constructor {
    'class: "java.io.File",
    paramTypes: ["java.lang.String", "java.lang.String"]
} external;

function java_io_File_newFile4(handle arg0) returns handle = @java:Constructor {
    'class: "java.io.File",
    paramTypes: ["java.net.URI"]
} external;

