-- Load mini.test
local MiniTest = require("mini.test")

local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

-- Create (but not start) child Neovim object
local child = MiniTest.new_child_neovim()

-- Load the RepoMap module
-- Adjust the path as necessary to point to your RepoMap module
-- local RepoMap = require("avante.utils.repo_map")

-- Define main test set of this file
local T = new_set({
  -- Register hooks
  hooks = {
    -- This will be executed before every (even nested) case
    pre_case = function()
      -- Restart child process with custom 'init.lua' script
      child.restart({ "-u", "scripts/minimal_init.lua" })
      -- Load tested plugin
      child.lua([[M = require('avante.utils.repo_map')]])
    end,
    -- This will be executed one after all tests from this set are finished
    post_once = child.stop,
  },
})

-- -- Test RepoMap.get_filetype_by_filepath
-- T["get_filetype_by_filepath"] = function()
--   local filetype = RepoMap.get_filetype_by_filepath("test.lua")
--   MiniTest.expect.equality(filetype, "lua")
-- end
--
-- -- Test RepoMap.get_repo_map
-- T["get_repo_map"] = function()
--   local repo_map = RepoMap.get_repo_map()
--   MiniTest.expect.table(repo_map)
-- end
--
-- -- Test RepoMap.extract_definitions
-- T["extract_definitions"] = function()
--   -- Create a temporary buffer with some Lua content
--   local bufnr = vim.api.nvim_create_buf(false, true)
--   vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
--     "function test_function()",
--     "  print('Hello, world!')",
--     "end",
--     "",
--     "local test_variable = 42",
--   })
--   vim.bo[bufnr].filetype = "lua"
--
--   -- Get the file path of the temporary buffer
--   local filepath = vim.api.nvim_buf_get_name(bufnr)
--
--   -- Extract definitions
--   local definitions = RepoMap.extract_definitions(filepath)
--
--   -- Clean up the temporary buffer
--   vim.api.nvim_buf_delete(bufnr, { force = true })
--
--   MiniTest.expect.table(definitions)
--   MiniTest.expect.equality(#definitions, 2)
-- end
--
-- -- Test RepoMap.stringify_definitions
-- T["stringify_definitions"] = function()
--   -- Create a temporary buffer with some Lua content
--   local bufnr = vim.api.nvim_create_buf(false, true)
--   vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
--     "function test_function()",
--     "  print('Hello, world!')",
--     "end",
--     "",
--     "local test_variable = 42",
--   })
--   vim.bo[bufnr].buftype = "lua"
--
--   -- Get the file path of the temporary buffer
--   local filepath = vim.api.nvim_buf_get_name(bufnr)
--
--   -- Stringify definitions
--   local stringified = RepoMap.stringify_definitions(filepath)
--
--   -- Clean up the temporary buffer
--   vim.api.nvim_buf_delete(bufnr, { force = true })
--
--   MiniTest.expect.string(stringified)
--   MiniTest.expect.match(stringified, "func test_function")
--   MiniTest.expect.match(stringified, "var test_variable")
-- end
T["get_repo_map()"] = new_set()
T["get_repo_map()"]["returns expected output"] = function()
  child.lua_get([[M.get_repo_map('deps/todomvc/examples/javascript-es6/src/model.js')]])
  -- Execute Lua code inside child process, get its result and compare with expected result
  --  eq(
  --    child.lua_get([[M.repoMap('deps/todomvc/examples/javascript-es6/src')]]),
  --    [[
  --deps/todomvc/examples/javascript-es6/src/model.js:
  --class Model {
  --    constructor(storage) {
  --    create(title, callback) {
  --    read(query, callback) {
  --    update(id, data, callback) {
  --    remove(id, callback) {
  --    removeAll(callback) {
  --    getCount(callback) {
  --
  --deps/todomvc/examples/javascript-es6/src/view.js:
  --const ENTER_KEY = 13;
  --export default class View {
  --    constructor(template) {
  --    _clearCompletedButton(completedCount, visible) {
  --    render(viewCmd, parameter) {
  --    bindCallback(event, handler) {
  --
  --deps/todomvc/examples/javascript-es6/src/controller.js:
  --class Controller {
  --    constructor(model, view) {
  --    setView(hash) {
  --    showAll() {
  --    showActive() {
  --    showCompleted() {
  --    addItem(title) {
  --    editItem(id) {
  --    editItemSave(id, title) {
  --    editItemCancel(id) {
  --    removeItem(id) {
  --    removeCompletedItems() {
  --    toggleComplete(id, completed, silent) {
  --    toggleAll(completed) {
  --    _updateCount() {
  --    _filter(force) {
  --    _updateFilter(currentPage) {
  --
  --deps/todomvc/examples/javascript-es6/src/store.js:
  --let uniqueID = 1;
  --export class Store {
  --    constructor(name, callback) {
  --    find(query, callback) {
  --    findAll(callback) {
  --    save(updateData, callback, id) {
  --    remove(id, callback) {
  --    drop(callback) {
  --
  --deps/todomvc/examples/javascript-es6/src/template.js:
  --const htmlEscapes = {
  --class Template {
  --    show(data) {
  --    itemCounter(activeTodos) {
  --    clearCompletedButton(completedTodos) {
  --
  --]]
  --   )
end

-- Return the test set
return T
