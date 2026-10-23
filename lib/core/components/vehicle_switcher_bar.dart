import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platku/core/constants/colors.dart';
import 'package:platku/core/utils/formatters.dart';
import 'package:platku/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:platku/presentation/blocs/vehicle/vehicle_event.dart';
import 'package:platku/presentation/blocs/vehicle/vehicle_state.dart';

class VehicleSwitcherBar extends StatelessWidget {
  const VehicleSwitcherBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<VehicleBloc?>();
    final state = bloc?.state;
    if (state is! VehicleLoaded || state.vehicles.isEmpty) {
      return const SizedBox.shrink();
    }

    final vehicles = state.vehicles;
    final selectedIdx = state.selectedIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: vehicles.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final v = vehicles[index];
            final isSelected = index == selectedIdx;
            final isMotor = v.type.toLowerCase() == 'motor';

            return GestureDetector(
              onTap: () {
                if (!isSelected) {
                  context.read<VehicleBloc>().add(SelectVehicle(index));
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isMotor
                          ? Icons.two_wheeler_rounded
                          : Icons.directions_car_filled_rounded,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      v.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.18)
                            : AppColors.surface2,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '${v.plateNumber} · ${Formatters.thousands(v.initialOdometer.round())} km',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.95)
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
