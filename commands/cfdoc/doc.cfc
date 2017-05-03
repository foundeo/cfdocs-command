/**
 * Shows documentation for CFML tags and functions. From the cfdocs.org project.
 * .
 * Examples
 * {code:bash}
 * doc rereplace
 * doc rereplace examples
 * doc cfdump full
 * doc hash args
 * {code}
 **/
component extends="commandbox.system.BaseCommand" aliases="doc" excludeFromHelp=false {

	variables.nameArgCache = [];

	/**
	* @name.hint The tag or function name
	* @name.optionsUDF autocompleteName
	* @mode.hint One of the following: default, examples, full, arguments, attributes
	* @mode.options default,examples,full,arguments,attributes
	**/
	function run( required name, mode="default")  {
        arguments.name = LCase(Left(ReReplace(arguments.name, "[^a-zA-Z0-9-]", "", "ALL"), 100));
        var doc = getDoc(name);

        if (!StructIsEmpty(doc)) {
            if (arguments.mode == "default" || arguments.mode == "full") {
                print.boldText(doc.name).print("  " & doc.description).line()
                	.line(RepeatString("-", shell.getTermWidth() ))
                	.cyan(doc.syntax);
                if (doc.type == "function" && StructKeyExists(doc, "returns") && Len(doc.returns)) {
                    print.cyan(' -> returns ').cyan(doc.returns);
                }
                print.line()
                	.line(RepeatString("-", shell.getTermWidth() ));
                if (structKeyExists(doc, "params") AND ArrayLen(doc.params)) {
                    print.line();

                    showParams(doc, arguments.mode);
                }
                if (arguments.mode == "full") {
                    print.line();
                    showExamples(doc);
                } else if (StructKeyExists(doc, "examples") AND !ArrayIsEmpty(doc.examples)) {
                    print.line().line()
                    	.yellow("Tip: type ").yellowBold("doc " & doc.name & " examples").yellow(" to see examples.")
                }
            }
            else if (arguments.mode == "examples" || arguments.mode == "ex") {
                showExamples(doc);
            } else if (arguments.mode == "arguments" || arguments.mode =="args" || arguments.mode == "attributes" || arguments.mode == "attr") {
				showParams(doc);
            } else {
                print.boldRedLine("Sorry I don't know mode: " & arguments.mode)
	                .line()
	                .line("Please try one of these modes:")
	                .indentedBold("default").line(" - this is the default if you don't specify a mode.")
	                .indentedBold("full").line(" - shows as much information as possible, verbose.")
	                .indentedBold("examples").line(" - shows examples of the tag/function. Shortcut: ex")
	                .indentedBold("arguments").line(" - shows only the function arguments. Shortcut: args")
	                .indentedBold("attributes").line(" - shows tag attributes. Shortcut: attr");

            }
        } else {
            print.redLine("Sorry no docs for that on cfdocs.org go add it: https://github.com/foundeo/cfdocs");
        }



	}

    private function showParams(doc, mode) {
        if (structKeyExists(doc, "params") AND ArrayLen(doc.params)) {
            if (doc.type == "tag") {
                print.boldText("Attributes").line();
            } else {
                print.boldText("Arguments").line();
            }
            if (arguments.mode != "default") {
                for (local.p in doc.params) {
                    local.notRequired = StructKeyExists(local.p, "required") AND !local.p.required;
                    if (local.notRequired) {
                        print.indentedBoldMagenta("[" & local.p.name & "]");
                    } else {
                        print.indented("").underscoredBoldMagenta(local.p.name);
                    }
                    if (structKeyExists(local.p, "description")) {
                        print.indentedmagenta(" - " & local.p.description);
                    }
                    print.line();
                }
            } else {
                local.pList = "  ";

                for (local.p in doc.params) {
                    local.notRequired = StructKeyExists(local.p, "required") AND !local.p.required;
                    if (local.notRequired) {
                        local.pList = local.pList & " [" & local.p.name & "]";
                    } else {
                        local.pList = local.pList & " " & local.p.name;
                    }
                }
                print.magenta(local.pList);
            }
        }
    }

    private function showExamples(doc) {
        print.boldTextLine(doc.name & " - Examples");
        if (StructKeyExists(doc, "examples") AND !ArrayIsEmpty(doc.examples)) {
            for (local.e in doc.examples) {
                print.line(RepeatString("-", shell.getTermWidth() ))
                	.bold(local.e.title).line(" " & local.e.description)
                	.line().magenta(local.e.code);
                if (structKeyExists(local.e, "result") && Len(local.e.result)) {
                    print.line().boldLine("Expected Result: " & local.e.result);
                }
            }
        } else {
            print.redLine("Sorry there are no examples for " & doc.name & " currently. But you can add one, please submit a pull request to: https://github.com/foundeo/cfdocs");
        }
    }


    private function getDoc(required name) {
        cfhttp(url="https://raw.githubusercontent.com/foundeo/cfdocs/master/data/en/#arguments.name#.json", result="local.httpResult", method="get");
        if (local.httpResult.statuscode contains "200") {
            local.doc = deserializeJSON(local.httpResult.fileContent);
            //cachePut("cfdocs_"&arguments.name, local.doc, CreateTimeSpan(0,1,0,0), CreateTimeSpan(0,1,0,0), "cfdocs");
            return local.doc;
        } else {
            return {};
        }
    }

    function autocompleteName() {
		if (ArrayLen(variables.nameArgCache) == 0) {
			variables.nameArgCache = listToArray( structKeyList( getFunctionList() ) );
			cfhttp(url="https://raw.githubusercontent.com/foundeo/cfdocs/master/data/en/index.json", result="local.httpResult", method="get");
	        if (local.httpResult.statuscode contains "200") {
	            local.doc = deserializeJSON(local.httpResult.fileContent);
				//add any functions not in getFunctionList
				for (local.f in local.doc.functions) {
					if (!ArrayFindNoCase(variables.nameArgCache, local.f)) {
						ArrayAppend(variables.nameArgCache, local.f);
					}
				}
				ArrayAppend(variables.nameArgCache, local.doc.tags, true);
			}

		}
    	return variables.nameArgCache;
    }


}
