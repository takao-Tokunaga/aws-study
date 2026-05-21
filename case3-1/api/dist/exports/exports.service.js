"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExportsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const client_sqs_1 = require("@aws-sdk/client-sqs");
const export_job_entity_1 = require("./export-job.entity");
const config_1 = require("@nestjs/config");
const s3_service_1 = require("../s3/s3.service");
let ExportsService = class ExportsService {
    constructor(repo, config, s3) {
        this.repo = repo;
        this.config = config;
        this.s3 = s3;
        this.sqs = new client_sqs_1.SQSClient({ region: config.get('AWS_REGION', 'ap-northeast-1') });
        this.queueUrl = config.get('SQS_QUEUE_URL', '');
    }
    async createJob() {
        const job = await this.repo.save(this.repo.create({ status: 'pending' }));
        await this.sqs.send(new client_sqs_1.SendMessageCommand({
            QueueUrl: this.queueUrl,
            MessageBody: JSON.stringify({ jobId: job.id }),
        }));
        return job;
    }
    async getJob(id) {
        const job = await this.repo.findOneOrFail({ where: { id } });
        if (job.status === 'complete' && job.s3Key) {
            const downloadUrl = await this.s3.getSignedUrl(job.s3Key, 3600);
            return { ...job, downloadUrl };
        }
        return job;
    }
};
exports.ExportsService = ExportsService;
exports.ExportsService = ExportsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(export_job_entity_1.ExportJob)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        config_1.ConfigService,
        s3_service_1.S3Service])
], ExportsService);
