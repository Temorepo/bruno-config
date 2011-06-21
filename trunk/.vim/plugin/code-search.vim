python << EOF

asLastPrefix = ""
class UserSkip(Exception):
    pass

def getInput(prompt, default=None):
    if default is not None:
        prompt += " or blank for '%s'" % default
    vim.command('let theUsersInput=input("%s: ")' % prompt)
    result = vim.eval("theUsersInput")
    if result is None:
        raise UserSkip
    if result.strip() == "":
        if default is None:
            raise UserSkip
        return default
    return result.strip()

def executeSearch():
    vim.command("normal wbyw")
    wordUnderCursor = vim.eval("getreg()").strip()
    if wordUnderCursor:
        # If there's anything other than whitespace under the cursor, use that by default.
        searchTerm = getInput("Enter term", wordUnderCursor)
    else:
         # Otherwise require user input
         searchTerm = getInput("Search for")
    print "Searching for", searchTerm

    # If the term looks like a field, class, or method, allow search refinements to be added
    restrictions = []
    if searchTerm[0] == "_" or (searchTerm[0].isupper() and searchTerm[-1].isupper()):
        # Add field restrictions for protected fields and constants
        restrictions = [("Definition", r"(var\|const) %s"),
            ("Access", "(?<!const )(?<!var )%s")]
    elif searchTerm[0].isupper() and (not searchTerm[-1].isalpha() or searchTerm[-1].islower()):
        # Camel-cased items get class restrictions
        restrictions = [("Subtype", r"(implements\|extends).* %s[^A-Za-z]"),
            ("Instantiation", r"new %s")]
    elif searchTerm[0].islower():
        # Field or function restrictions for starting with a lowercase letter
        restrictions = [("Definition", r"(var\|const\|function) %s"),
            ("Access", "(?<!const )(?<!var )(?<!function )%s")]
    if restrictions:
        for idx, option in enumerate(restrictions):
            print "%s: %s" % (idx + 1, option[0])
        idx = getInput("Restriction", searchTerm)
        if idx != searchTerm:
            searchTerm = restrictions[int(idx) - 1][1] % searchTerm

    # Strip out all imports; I'm counting on imports being the first character.
    # Attempting to find indented imports while not accidentally picking up field and method
    # accesses starting with i is beyond my regexp abilities.
    searchTerm = "^[^i].*%s" % searchTerm

    # Allow a subset of the as directories to be specified, defaulting to the last subset
    global asLastPrefix
    prefix = getInput("Directory prefix to search", asLastPrefix)
    filetype = vim.eval("&filetype")
    vim.command("Ack '%s' ~/garage/%s*/src -w --no-column --%s" %
        (searchTerm, prefix, filetype))
    asLastPrefix = prefix

def runUserInputFunc(func):
    try:
        func()
    except UserSkip:
        pass

EOF

noremap <leader>F :python runUserInputFunc(executeSearch)<CR>
