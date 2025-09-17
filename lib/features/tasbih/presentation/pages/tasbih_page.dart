import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../cubit/tasbih_cubit.dart';

class TasbihPage extends StatelessWidget {
  static const routeName = '/tasbih';

  const TasbihPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TasbihCubit>(),
      child: const _TasbihView(),
    );
  }
}

class _TasbihView extends StatelessWidget {
  const _TasbihView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'المسبحة الإلكترونية',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.background,
                colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header with Islamic decoration
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'سبحان الله وبحمده',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Counter display
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: BlocBuilder<TasbihCubit, TasbihState>(
                        builder: (context, state) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${state.counter}',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              const Text(
                                'تسبيحة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // Action buttons
                  Row(
                    children: [
                      // Increment button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => context.read<TasbihCubit>().increment(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline, size: 28),
                              SizedBox(width: 8),
                              Text(
                                'تسبيحة',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Reset button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.read<TasbihCubit>().reset(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh, size: 24),
                              SizedBox(height: 4),
                              Text(
                                'إعادة',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Tips text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'اضغط على زر التسبيحة لزيادة العداد واضغط على إعادة لبدء عد جديد',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
