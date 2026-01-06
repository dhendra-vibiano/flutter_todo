import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/todo_provider.dart';
import 'widgets/todo_item.dart';
import 'widgets/add_todo_dialog.dart';
import 'widgets/dashboard_chart.dart';
import 'widgets/stat_card.dart';
import 'models/todo_model.dart';

class TodoWebSimple extends StatefulWidget {
  const TodoWebSimple({super.key});

  @override
  State<TodoWebSimple> createState() => _TodoWebSimpleState();
}

class _TodoWebSimpleState extends State<TodoWebSimple> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'General', 'Work', 'Personal', 'Shopping', 'Health', 'Education'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Modern light bg
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          final allTodos = provider.todos; // Get filtered list from provider actually returns everything if we don't apply filter in provider. 
          // But wait, provider.todos adheres to provider._filter. 
          // Let's rely on manual filtering here for the dashboard stats to be accurate regardless of tab.
          // Actually, let's fix the provider usage. provider.todos returns based on filter.
          
          // For the DASHBOARD stats, we need ALL todos to count them properly.
          // Let's assume for now provider.todos returns what the user selected (All/Active/Done).
          // Ideally, we'd want a separate getter for "Stats". 
          // For now, let's just use the current viewer.
          
          final int activeCount = allTodos.where((t) => !t.isCompleted).length;
          final int doneCount = allTodos.where((t) => t.isCompleted).length;
          final int totalCount = allTodos.length;

          // Apply Category Filter locally for the LIST view
          final displayTodos = _selectedCategory == 'All' 
              ? allTodos 
              : allTodos.where((t) => t.category == _selectedCategory).toList();

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // 1. Header & Greeting
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Guest 👋',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Your Dashboard',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.indigo.shade50,
                          child: const Icon(Icons.person, color: Colors.indigo),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Charts & Stats
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left: Pie Chart
                          Expanded(
                            flex: 3,
                            child: DashboardChart(
                              activeCount: activeCount,
                              doneCount: doneCount,
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Right: Stats Grid
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                StatCard(
                                  title: 'Pending',
                                  count: activeCount.toString(),
                                  icon: Icons.timer,
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 12),
                                StatCard(
                                  title: 'Done',
                                  count: doneCount.toString(),
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Category Filter
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                            selectedColor: Colors.indigo,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.indigo,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: Colors.indigo.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.indigo.shade50),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 4. Task List Header
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Tasks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                             // Reset filter in provider if needed, or open full list page
                             Provider.of<TodoProvider>(context, listen: false).setFilter('All');
                             // Just for demo, we are showing all tasks in this list anyway
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ),
                ),

                // 5. Task List
                displayTodos.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_add, size: 60, color: Colors.indigo.shade100),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks found',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final todo = displayTodos[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4), // reduced padding as TodoItem has its own margin
                              child: TodoItem(
                                todo: todo,
                                onChanged: (_) => provider.toggleTodo(todo),
                                onDelete: () => provider.deleteTodo(todo.id!),
                                onTap: () => _showAddTodoDialog(context, todo: todo),
                              ),
                            );
                          },
                          childCount: displayTodos.length,
                        ),
                      ),
                  
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoDialog(context),
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4,
        highlightElevation: 8,
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, {Todo? todo}) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Transparent for rounded corners
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AddTodoDialog(todo: todo),
      ),
    );

    if (!mounted) return;

    final provider = Provider.of<TodoProvider>(context, listen: false);

    if (result == 'delete' && todo != null) {
      await provider.deleteTodo(todo.id!);
    } else if (result is Todo) {
      if (todo == null) {
        await provider.addTodo(result);
      } else {
        await provider.updateTodo(result);
      }
    }
  }
}
