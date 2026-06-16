import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/models/fuel_receipt_model.dart';
import 'package:driving_school/models/maintenance_receipt_model.dart';
import 'package:driving_school/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class AdminFinanceScreen extends StatefulWidget {
  const AdminFinanceScreen({super.key});

  @override
  State<AdminFinanceScreen> createState() => _AdminFinanceScreenState();
}

class _AdminFinanceScreenState extends State<AdminFinanceScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false).fetchAllInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Provider.of<AdminController>(context);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financial Profit/Loss',
          style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<FuelReceiptModel>>(
        stream: adminCtrl.getAllFuelReceipts(),
        builder: (context, fuelSnapshot) {
          if (fuelSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<MaintenanceReceiptModel>>(
            stream: adminCtrl.getAllMaintenanceReceipts(),
            builder: (context, maintSnapshot) {
              if (maintSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // 1. CALCULATE REVENUE (Incomes)
              double totalRevenue = 0.0;
              List<TransactionModel> transactions = [];

              for (var invoice in adminCtrl.invoiceList) {
                try {
                  DateTime date = DateTime.parse(invoice.invoiceDate);
                  
                  transactions.add(TransactionModel(
                    title: 'Course Sale: ${invoice.invoiceCourseName}',
                    subtitle: 'Student: ${invoice.invoiceUserName}',
                    amount: invoice.invoicePrice,
                    date: date,
                    isIncome: true,
                    icon: Iconsax.wallet_add,
                  ));

                  if (date.year == now.year && date.month == now.month) {
                    totalRevenue += invoice.invoicePrice;
                  }
                } catch (e) {
                  // Ignore parse errors silently for analytics
                }
              }

              // 2. CALCULATE EXPENSES (Fuel & Maintenance)
              double totalExpenses = 0.0;
              
              // Add Fuel Logs
              final fuelLogs = fuelSnapshot.data ?? [];
              for (var fuel in fuelLogs) {
                if (fuel.status == 'Approved') {
                  DateTime date = DateTime.parse(fuel.date);
                  
                  transactions.add(TransactionModel(
                    title: 'Fuel Refill: ${fuel.vehiclePlate}',
                    subtitle: 'Logged by ${fuel.instructorName}',
                    amount: double.parse(fuel.amount),
                    date: date,
                    isIncome: false,
                    icon: Iconsax.gas_station,
                  ));

                  if (date.year == now.year && date.month == now.month) {
                    totalExpenses += double.parse(fuel.amount);
                  }
                }
              }

              // Add Maintenance Logs
              final maintLogs = maintSnapshot.data ?? [];
              for (var maint in maintLogs) {
                if (maint.status == 'Approved') {
                  DateTime date = maint.date;
                  
                  transactions.add(TransactionModel(
                    title: 'Repair: ${maint.vehiclePlate}',
                    subtitle: 'Logged by ${maint.instructorName}',
                    amount: maint.amount,
                    date: date,
                    isIncome: false,
                    icon: Iconsax.warning_2,
                  ));

                  if (date.year == now.year && date.month == now.month) {
                    totalExpenses += maint.amount;
                  }
                }
              }

              // 3. SORT TRANSACTIONS (Newest first)
              transactions.sort((a, b) => b.date.compareTo(a.date));

              // 4. NET PROFIT
              double netProfit = totalRevenue - totalExpenses;
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryHeader(totalRevenue, totalExpenses, netProfit),
                    const SizedBox(height: 30),
                    Text(
                      'Recent Transactions',
                      style: GoogleFonts.epilogue(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    transactions.isEmpty 
                      ? const Center(child: Text("No transactions available"))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          separatorBuilder: (context, index) => const Divider(height: 20),
                          itemBuilder: (context, index) {
                            final txn = transactions[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: txn.isIncome ? Colors.green.shade50 : Colors.red.shade50,
                                child: Icon(
                                  txn.icon,
                                  color: txn.isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(
                                txn.title,
                                style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: Text(
                                '${txn.date.day}/${txn.date.month}/${txn.date.year} • ${txn.subtitle}',
                                style: GoogleFonts.epilogue(fontSize: 12),
                              ),
                              trailing: Text(
                                '${txn.isIncome ? '+' : '-'} ₹${txn.amount.toStringAsFixed(0)}',
                                style: GoogleFonts.epilogue(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: txn.isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          },
                        )
                  ],
                ),
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildSummaryHeader(double revenue, double expenses, double profit) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'This Month',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Profit Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: profit >= 0 
                  ? [Colors.green.shade600, Colors.green.shade400]
                  : [Colors.red.shade600, Colors.red.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: (profit >= 0 ? Colors.green : Colors.red).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ]
          ),
          child: Column(
            children: [
              Text(
                'Net Profit',
                style: GoogleFonts.epilogue(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '₹${profit.toStringAsFixed(0)}',
                style: GoogleFonts.epilogue(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        
        // Income / Expenses Split
        Row(
          children: [
            Expanded(
              child: _buildSubCard('Revenue', revenue, Colors.green, Iconsax.arrow_bottom),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildSubCard('Expenses', expenses, Colors.red, Icons.arrow_upward),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSubCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.epilogue(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w600
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: GoogleFonts.epilogue(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
