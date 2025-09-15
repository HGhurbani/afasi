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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المسبحة الإلكترونية'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'عدد التسبيحات:',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: theme.primaryColor, width: 1),
                ),
                child: BlocBuilder<TasbihCubit, TasbihState>(
                  builder: (context, state) {
                    return Text(
                      '${state.counter}',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => context.read<TasbihCubit>().increment(),
                icon: const Icon(Icons.add_circle_outline, size: 28),
                label: const Text(
                  'تسبيحة',
                  style: TextStyle(fontSize: 20, fontFamily: 'Tajawal'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
              const SizedBox(height: 15),
              TextButton.icon(
                onPressed: () => context.read<TasbihCubit>().reset(),
                icon: const Icon(Icons.refresh, size: 24),
                label: const Text(
                  'إعادة التعيين',
                  style: TextStyle(fontSize: 16, fontFamily: 'Tajawal'),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: isDarkMode ? Colors.white70 : Colors.black54,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
