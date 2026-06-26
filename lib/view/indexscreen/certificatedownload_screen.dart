import 'package:dio/dio.dart';
import 'package:firstedu/res/constants/colors/appcolors.dart';
import 'package:firstedu/res/widgets/custom_card.dart';
import 'package:firstedu/res/widgets/custom_silverappbar.dart';
import 'package:firstedu/res/widgets/custom_text.dart';
import 'package:firstedu/res/widgets/customheadercard.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';
import 'package:firstedu/view_models/certificatedownloadprovider/certificatedownload_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class CertificatesEarnedScreen extends StatefulWidget {
  const CertificatesEarnedScreen({super.key});

  @override
  State<CertificatesEarnedScreen> createState() =>
      _CertificatesEarnedScreenState();
}

class _CertificatesEarnedScreenState extends State<CertificatesEarnedScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CertificateDownloadProvider>().fetchCertificates(context);
    });
  }

  Future<void> downloadPdf(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    try {
      // ✅ App internal directory (NO permission needed)
      final dir = await getApplicationDocumentsDirectory();

      final safeName = fileName.replaceAll(RegExp(r'[^\w\s]+'), '');
      final path = "${dir.path}/$safeName.pdf";

      // ✅ Download
      await Dio().download(url, path);

      // ✅ Success
      AppToast.success(
        context,
        title: "Downloaded",
        message: "Saved successfully",
      );

      // ✅ Open file
      await OpenFile.open(path);
    } catch (e) {
      AppToast.error(context, message: "Download failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CertificateDownloadProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(
            title: "Certificates Earned",
            subtitle: "Your achievements and earned certificates",
          ),

          SliverPadding(
            padding: EdgeInsets.all(16.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header with Icon
                const BubbleHeaderCard(
                  title: "Cetificates Earned",
                  subtitle: "Your achievements and earned certificates",
                  icon: Icons.workspace_premium_rounded,
                  backgroundColor: drawerColor,
                  iconColor: successColor, // Gold color
                ),
                SizedBox(height: 24.h),

                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (provider.certificates.isEmpty)
                  const Center(child: Text("No certificates found"))
                else ...[
                  _buildTotalCard(provider.certificates.length),
                  SizedBox(height: 20.h),
                  _buildCertificatesCard(provider),
                ],
                SizedBox(height: 100.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(int count) {
    return CustomCard(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: successColor,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "TOTAL CERTIFICATES",
                size: 12,
                weight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
              SizedBox(height: 4.h),
              CustomText(
                text: count.toString(),
                size: 36,
                weight: FontWeight.w800,
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesCard(CertificateDownloadProvider provider) {
    return CustomCard(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: "Your Certificates",
            size: 20,
            weight: FontWeight.w800,
            color: Colors.black87,
          ),
          SizedBox(height: 20.h),

          ...provider.certificates.asMap().entries.map((entry) {
            final index = entry.key;
            final cert = entry.value;
            return _buildCertificateItem(
              cert,
              isLast: index == provider.certificates.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCertificateItem(cert, {bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// CERTIFICATE ICON
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: successColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: successColor,
              size: 26.sp,
            ),
          ),

          14.w.horizontalSpace,

          /// CERTIFICATE DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: cert.title ?? "No Title",
                  size: 15,
                  weight: FontWeight.w700,
                  maxLines: 2,
                  color: Colors.black87,
                ),
                6.h.verticalSpace,
                CustomText(
                  text:
                      "Issued: ${cert.issuedAt?.toLocal().toString().split(' ')[0] ?? "-"} • ID: ${cert.id ?? "-"}",
                  size: 12,
                  color: Colors.grey.shade600,
                  maxLines: 2,
                ),
              ],
            ),
          ),

          10.w.horizontalSpace,

          /// DOWNLOAD BUTTON (TOP ALIGNED)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [_downloadButton(cert)],
          ),
        ],
      ),
    );
  }

  Widget _downloadButton(cert) {
    return Material(
      color: successColor,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: () {
          final url = cert.pdfUrl;

          if (url != null && url.isNotEmpty) {
            downloadPdf(context, url, cert.title ?? "certificate");
          } else {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text("Invalid PDF URL")),
            // );
            AppToast.error(context, message: "Invalid PDF URL");
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_rounded, color: Colors.white, size: 18.sp),
              6.w.horizontalSpace,
              const CustomText(
                text: "PDF",
                size: 12,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
